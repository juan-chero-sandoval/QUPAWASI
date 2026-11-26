-- C05. Run against the schema exported by the project before enabling mobile writes.
begin;

alter table public.activity
  add column point_id text references public.recycle_points(id) on delete set null,
  add column capture_id uuid unique,
  add column note text not null default '' check (char_length(note) <= 200);

alter table public.redemptions
  add column operation_id uuid,
  add column stock_reserved boolean,
  add column canceled_at timestamptz,
  add constraint redemptions_fulfilled_or_canceled
    check (not (fulfilled and canceled_at is not null));

create unique index redemptions_user_operation_uidx
  on public.redemptions (user_id, operation_id)
  where operation_id is not null;

create unique index redemptions_mobile_code_uidx
  on public.redemptions (code)
  where operation_id is not null;

create index redemptions_user_created_idx
  on public.redemptions (user_id, created_at desc, id desc);

-- The internal credit helper is only called by controlled procedures.
revoke execute on function public._apply_recycling_credit(uuid, text, jsonb, public.activity_source, double precision, double precision)
  from public, anon, authenticated;
revoke execute on function public.consume_device_capture(uuid)
  from public, anon, authenticated;
-- QR captures are the authoritative source for regular accounts.
revoke execute on function public.register_recycling(jsonb, text, public.activity_source, double precision, double precision)
  from public, anon, authenticated;
revoke insert, update, delete, truncate on public.activity, public.device_captures
  from public, anon, authenticated;
revoke insert, delete, truncate on public.redemptions from public, anon, authenticated;
revoke update on public.redemptions from public, anon;
drop policy "device_captures: select pending" on public.device_captures;
create policy "device_captures: admin read"
  on public.device_captures for select to authenticated using (public.is_admin());

create or replace function public.submit_device_capture(
  p_point_id text, p_device_secret text, p_items jsonb, p_raw_label text default null
) returns public.device_captures
language plpgsql security definer set search_path = ''
as $function$
declare
  v_secret text;
  v_capture public.device_captures;
begin
  select s.secret into v_secret from public.device_secrets s
  join public.recycle_points p on p.id = s.point_id and p.enabled
  where s.point_id = p_point_id;

  if v_secret is null or p_device_secret is distinct from v_secret then
    raise exception 'Punto o secreto de dispositivo inválido' using errcode = '42501';
  end if;
  if jsonb_typeof(p_items) is distinct from 'array' then
    raise exception 'Envío de materiales inválido';
  end if;
  if jsonb_array_length(p_items) not between 1 and 20 then
    raise exception 'Envío de materiales inválido';
  end if;
  insert into public.device_captures (point_id, items, raw_label)
  values (p_point_id, p_items, p_raw_label)
  returning * into v_capture;
  return v_capture;
end;
$function$;

-- The two read/write operations disclose capture details only by exact receipt ID.
create function public.preview_mobile_capture(p_capture_id uuid)
returns table(id uuid, point_id text, point_name text, items jsonb, created_at timestamptz, requires_location boolean)
language plpgsql stable security definer set search_path = ''
as $function$
declare
  v_user uuid := auth.uid();
begin
  if v_user is null then
    raise exception 'Inicia sesión' using errcode = '42501';
  end if;
  return query
    select c.id, c.point_id, p.name, c.items, c.created_at, p.lat is not null and p.lng is not null
    from public.device_captures c
    join public.recycle_points p on p.id = c.point_id and p.enabled
    where c.id = p_capture_id
      and (
        (not c.consumed and c.created_at >= now()
          - make_interval(mins => public._setting_number('capture_expiry_minutes', 3)::integer))
        or exists (select 1 from public.activity a where a.capture_id = c.id and a.user_id = v_user)
      );
end;
$function$;

create or replace function public.claim_device_capture(
  p_capture_id uuid, p_lat double precision default null, p_lng double precision default null
) returns public.activity
language plpgsql security definer set search_path = ''
as $function$
declare
  v_user uuid := auth.uid();
  v_capture public.device_captures;
  v_entry public.activity;
begin
  if v_user is null then
    raise exception 'Inicia sesión' using errcode = '42501';
  end if;

  select * into v_capture from public.device_captures where id = p_capture_id for update;
  select * into v_entry from public.activity where capture_id = p_capture_id and user_id = v_user;
  if found then return v_entry; end if;

  if v_capture.id is null or v_capture.consumed or v_capture.created_at < now()
      - make_interval(mins => public._setting_number('capture_expiry_minutes', 3)::integer) then
    raise exception 'La captura expiró o ya no está disponible.';
  end if;
  if (p_lat is null) <> (p_lng is null)
      or (p_lat is not null and (p_lat not between -90 and 90 or p_lng not between -180 and 180)) then
    raise exception 'La ubicación es inválida.';
  end if;

  -- Serializes the cooldown, daily cap, totals and streak of this user.
  perform 1 from public.profiles where id = v_user for update;
  if not found then raise exception 'Tu cuenta todavía no tiene un perfil.'; end if;

  v_entry := public._apply_recycling_credit(
    v_user, v_capture.point_id, v_capture.items, 'esp32', p_lat, p_lng
  );
  update public.activity set point_id = v_capture.point_id, capture_id = v_capture.id
    where id = v_entry.id returning * into v_entry;
  update public.device_captures set consumed = true where id = v_capture.id;
  return v_entry;
end;
$function$;

create function public.update_recycling_note(p_activity_id uuid, p_note text)
returns public.activity
language plpgsql security definer set search_path = ''
as $function$
declare
  v_entry public.activity;
begin
  if auth.uid() is null then raise exception 'Inicia sesión' using errcode = '42501'; end if;
  if p_note is null or char_length(p_note) > 200 then raise exception 'La nota admite hasta 200 caracteres.'; end if;
  update public.activity set note = btrim(p_note)
    where id = p_activity_id and user_id = auth.uid() and type = 'recycle'
    returning * into v_entry;
  if not found then raise exception 'Registro no encontrado.'; end if;
  return v_entry;
end;
$function$;

create function public.redeem_reward(p_reward_id text, p_operation_id uuid)
returns public.redemptions
language plpgsql security definer set search_path = ''
as $function$
declare
  v_user uuid := auth.uid();
  v_balance integer;
  v_reward public.rewards;
  v_redemption public.redemptions;
begin
  if v_user is null then raise exception 'Inicia sesión' using errcode = '42501'; end if;
  if p_operation_id is null then raise exception 'Falta el identificador del canje.'; end if;

  select * into v_redemption from public.redemptions
    where user_id = v_user and operation_id = p_operation_id;
  if found then
    if v_redemption.reward_id is distinct from p_reward_id then raise exception 'La operación corresponde a otro premio.'; end if;
    return v_redemption;
  end if;

  select * into v_reward from public.rewards where id = p_reward_id for update;
  select points into v_balance from public.profiles where id = v_user for update;

  select * into v_redemption from public.redemptions
    where user_id = v_user and operation_id = p_operation_id;
  if found then
    if v_redemption.reward_id is distinct from p_reward_id then raise exception 'La operación corresponde a otro premio.'; end if;
    return v_redemption;
  end if;
  if v_reward.id is null or not v_reward.enabled then raise exception 'Recompensa no disponible.'; end if;
  if v_reward.stock is not null and v_reward.stock <= 0 then raise exception 'La recompensa está agotada.'; end if;
  if v_balance is null or v_balance < v_reward.cost then raise exception 'Saldo insuficiente.'; end if;

  update public.profiles set points = points - v_reward.cost where id = v_user;
  if v_reward.stock is not null then
    update public.rewards set stock = stock - 1 where id = v_reward.id;
  end if;
  insert into public.activity (user_id, type, reward_id, reward_title, source, points)
    values (v_user, 'redeem', v_reward.id, v_reward.title, 'manual', -v_reward.cost);
  insert into public.redemptions (user_id, reward_id, reward_title, cost, code, operation_id, stock_reserved)
    values (v_user, v_reward.id, v_reward.title, v_reward.cost,
      'ECO-' || upper(replace(gen_random_uuid()::text, '-', '')), p_operation_id, v_reward.stock is not null)
    returning * into v_redemption;
  return v_redemption;
end;
$function$;

-- Retain the signature used by existing callers.
create or replace function public.redeem_reward(p_reward_id text)
returns public.redemptions
language sql security invoker set search_path = ''
as $function$
  select public.redeem_reward(p_reward_id, gen_random_uuid());
$function$;

create function public.cancel_mobile_redemption(p_redemption_id uuid)
returns public.redemptions
language plpgsql security definer set search_path = ''
as $function$
declare
  v_user uuid := auth.uid();
  v_redemption public.redemptions;
begin
  if v_user is null then raise exception 'Inicia sesión' using errcode = '42501'; end if;
  select * into v_redemption from public.redemptions
    where id = p_redemption_id and user_id = v_user for update;
  if not found then raise exception 'Canje no encontrado.'; end if;
  if v_redemption.canceled_at is not null then return v_redemption; end if;
  if v_redemption.fulfilled or v_redemption.stock_reserved is null then
    raise exception 'Este canje ya no se puede cancelar desde la app.';
  end if;

  -- Match the reward → profile lock order used by redeem_reward.
  if v_redemption.stock_reserved then
    update public.rewards set stock = stock + 1 where id = v_redemption.reward_id and stock is not null;
  end if;
  update public.profiles set points = points + v_redemption.cost where id = v_user;
  insert into public.activity (user_id, type, reward_id, reward_title, label, source, points)
    values (v_user, 'bonus', v_redemption.reward_id, v_redemption.reward_title,
            'Devolución de canje', 'system', v_redemption.cost);
  update public.redemptions set canceled_at = now() where id = v_redemption.id returning * into v_redemption;
  return v_redemption;
end;
$function$;

revoke execute on function public.preview_mobile_capture(uuid),
  public.claim_device_capture(uuid, double precision, double precision),
  public.update_recycling_note(uuid, text),
  public.redeem_reward(text, uuid), public.redeem_reward(text),
  public.cancel_mobile_redemption(uuid) from public, anon;

grant execute on function public.preview_mobile_capture(uuid),
  public.claim_device_capture(uuid, double precision, double precision),
  public.update_recycling_note(uuid, text),
  public.redeem_reward(text, uuid), public.redeem_reward(text),
  public.cancel_mobile_redemption(uuid) to authenticated;

notify pgrst, 'reload schema';

commit;
