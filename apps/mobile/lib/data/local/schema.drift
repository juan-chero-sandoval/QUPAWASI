CREATE TABLE recycling_points (
  id TEXT NOT NULL PRIMARY KEY,
  name TEXT NOT NULL CHECK (length(trim(name)) > 0),
  description TEXT NOT NULL,
  occupancy INTEGER NOT NULL CHECK (typeof(occupancy) = 'integer' AND occupancy BETWEEN 0 AND 100),
  latitude REAL,
  longitude REAL,
  is_demo INTEGER NOT NULL DEFAULT 1 CHECK (is_demo IN (0, 1))
);

CREATE TABLE recycling_records (
  id TEXT NOT NULL PRIMARY KEY,
  point_id TEXT NOT NULL REFERENCES recycling_points(id),
  material TEXT NOT NULL CHECK (material IN ('pet', 'aluminum')),
  quantity INTEGER NOT NULL CHECK (typeof(quantity) = 'integer' AND quantity BETWEEN 1 AND 100),
  unit_points INTEGER NOT NULL CHECK (typeof(unit_points) = 'integer' AND unit_points > 0),
  occurred_at INTEGER NOT NULL,
  note TEXT NOT NULL DEFAULT '' CHECK (length(note) <= 200),
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL
);
CREATE INDEX records_occurred_at ON recycling_records(occurred_at DESC, id);
CREATE INDEX records_point ON recycling_records(point_id);

CREATE TABLE rewards (
  id TEXT NOT NULL PRIMARY KEY,
  title TEXT NOT NULL,
  category TEXT NOT NULL CHECK (category IN ('photocopies', 'mobile', 'cafeteria')),
  cost_points INTEGER NOT NULL CHECK (typeof(cost_points) = 'integer' AND cost_points > 0),
  description TEXT NOT NULL,
  is_active INTEGER NOT NULL DEFAULT 1 CHECK (is_active IN (0, 1))
);

CREATE TABLE redemptions (
  id TEXT NOT NULL PRIMARY KEY,
  operation_id TEXT NOT NULL UNIQUE,
  reward_id TEXT NOT NULL REFERENCES rewards(id),
  title_snapshot TEXT NOT NULL,
  cost_snapshot INTEGER NOT NULL CHECK (typeof(cost_snapshot) = 'integer' AND cost_snapshot > 0),
  created_at INTEGER NOT NULL,
  canceled_at INTEGER
);

CREATE TABLE drafts (
  "key" TEXT NOT NULL PRIMARY KEY,
  record_id TEXT,
  point_id TEXT,
  material TEXT,
  quantity_text TEXT NOT NULL,
  note TEXT NOT NULL CHECK (length(note) <= 200),
  step INTEGER NOT NULL CHECK (step BETWEEN 0 AND 2),
  updated_at INTEGER NOT NULL,
  occurred_at INTEGER
);

CREATE TABLE suggestions (
  id TEXT NOT NULL PRIMARY KEY,
  message TEXT NOT NULL CHECK (length(trim(message)) BETWEEN 5 AND 500),
  created_at INTEGER NOT NULL
);

-- Defensa en SQLite: incluso dos conexiones no pueden gastar el mismo saldo.
-- Las tasas NO se duplican aquí: cada registro conserva su política demo aplicada.
CREATE TRIGGER protect_redemption_balance
BEFORE INSERT ON redemptions
WHEN NEW.canceled_at IS NULL AND (
  (SELECT coalesce(sum(quantity * unit_points), 0) FROM recycling_records) -
  (SELECT coalesce(sum(cost_snapshot), 0) FROM redemptions WHERE canceled_at IS NULL)
) < NEW.cost_snapshot
BEGIN
  SELECT RAISE(ABORT, 'insufficient_points');
END;

CREATE TRIGGER protect_record_update_balance
BEFORE UPDATE ON recycling_records
WHEN (
  (SELECT coalesce(sum(quantity * unit_points), 0) FROM recycling_records)
  - OLD.quantity * OLD.unit_points + NEW.quantity * NEW.unit_points
) < (SELECT coalesce(sum(cost_snapshot), 0) FROM redemptions WHERE canceled_at IS NULL)
BEGIN
  SELECT RAISE(ABORT, 'committed_points');
END;

CREATE TRIGGER protect_record_delete_balance
BEFORE DELETE ON recycling_records
WHEN (
  SELECT coalesce(sum(quantity * unit_points), 0) FROM recycling_records WHERE id != OLD.id
) < (SELECT coalesce(sum(cost_snapshot), 0) FROM redemptions WHERE canceled_at IS NULL)
BEGIN
  SELECT RAISE(ABORT, 'committed_points');
END;

CREATE TRIGGER immutable_redemption
BEFORE UPDATE ON redemptions
WHEN NEW.id != OLD.id OR NEW.operation_id != OLD.operation_id OR
  NEW.reward_id != OLD.reward_id OR NEW.title_snapshot != OLD.title_snapshot OR
  NEW.cost_snapshot != OLD.cost_snapshot OR NEW.created_at != OLD.created_at OR
  (OLD.canceled_at IS NOT NULL AND NEW.canceled_at IS NOT OLD.canceled_at)
BEGIN
  SELECT RAISE(ABORT, 'immutable_redemption');
END;
