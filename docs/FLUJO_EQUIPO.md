# Trabajo por turnos y commits propios

## Regla práctica

Un integrante trabaja a la vez sobre código de app. Cada uno empieza con `develop` actualizado, pide a su IA ejecutar su PRP, revisa el resultado, ejecuta las pruebas y hace commit desde su identidad. El owner revisa y fusiona. Tener acceso de colaborador no configura automáticamente Git ni permite a una IA sin terminal ejecutar Flutter.

No crear cinco commits cambiando artificialmente el autor. Cada persona debe poder explicar lo que hizo, como exige la rúbrica. Los commits deben contener código/pruebas propios, no solo cambiar un nombre en README.

## Publicar esta preparación — owner

Esta sesión deja cambios **sin commit ni push** en `codex/plan-equipo-unidad-2`. Revisa antes de ejecutar:

```powershell
git status --short
python scripts/validar_contexto.py
git diff --check
git add README.md AGENTS.md .gitignore .gitattributes docs prps scripts .agents .github
git diff --cached --stat
git commit -m "docs: preparar plan Unidad II y PRP del equipo"
git push -u origin codex/plan-equipo-unidad-2
```

Abre un PR de esta rama hacia `main` en GitHub, revísalo y fusiona con **Create a merge commit**. Después, sin cambios locales pendientes:

```powershell
git switch main
git pull --ff-only origin main
git switch -c develop
git push -u origin develop
```

Si `develop` ya existe local o remotamente, no recrearla: `git fetch origin`, seleccionar la existente y actualizar con `--ff-only`. No usar comandos de reset ni forzar. Si la preparación no se publicó, el compañero no la verá al clonar: este es el único paso de distribución pendiente antes de F01.

## Primer clon — cada integrante

```powershell
git clone https://github.com/juan-chero-sandoval/QUPAWASI.git
cd QUPAWASI
git fetch origin
git switch develop
git pull --ff-only origin develop
git config user.name
git config user.email
git remote -v
```

Si no existe seguimiento local: `git switch --track origin/develop`. Si falta identidad, cada persona configura **en este repo** su nombre y el correo verificado en su cuenta GitHub o su correo noreply; no copiar el correo de Juan. El acceso debe ser mediante su cuenta, no un token compartido.

## Comenzar cada turno

```powershell
git status --short
git fetch origin
git switch develop
git pull --ff-only origin develop
```

El estado debe estar limpio o los cambios deben haber sido conservados explícitamente antes de cambiar de rama. Luego crear **solo la rama de su fase**, por ejemplo para Cristhoper:

```powershell
git switch -c codex/f01-base-flutter
```

Para los otros turnos usar la rama indicada en el plan. Leer el informe de la fase anterior. Si hay conflictos o divergencias, pedir a la IA resolverlos conservando la funcionalidad y repetir validaciones; no usar `push --force` ni `reset --hard`.

## Mensaje común para la IA

> Estoy en mi turno del equipo Q'UPA WASI. Lee AGENTS.md, docs/CONTEXTO_GENERAL.md, docs/CONTRATOS.md, docs/FLUJO_EQUIPO.md, docs/ESTADO.md y el PRP de mi fase. Verifica que el turno anterior esté integrado. Implementa únicamente mi fase, valida cada criterio, conserva pruebas y contratos existentes y actualiza mi informe y el estado. No hagas trabajo del siguiente integrante ni inventes pruebas ejecutadas. Al finalizar prepara un commit con mi identidad Git existente y los resultados reales. Si mi sesión te autoriza expresamente a crearlo/publicarlo, hazlo; si no, deja los comandos exactos para que lo haga yo.

El mensaje específico de cada PRP completa nombre, rama y objetivo. “Al pie de la letra” se aplica a invariantes y aceptación; la IA puede adaptar detalles a versiones reales, documentando compatibilidad. Un PRP no puede garantizar cero bugs sin pruebas.

## Cerrar turno y publicar

1. Validar el PRP y regresión anterior.
2. Actualizar `docs/ESTADO.md` y `docs/entregas/FNN.md` usando la plantilla. No incluir el hash del propio commit dentro de sí mismo; anotar hash del código anterior si existe y agregar el definitivo a la descripción del PR o al siguiente handoff.
3. Revisar `git diff --check`, archivos nuevos y exclusiones de secretos/build.
4. Comprobar `git config user.name` y `git config user.email`.
5. Añadir explícitamente archivos de la fase, revisar `git diff --cached`, y commitear con el mensaje previsto en el PRP. No añadir cambios ajenos con `git add .` sin revisar.
6. Publicar su rama con `git push -u origin NOMBRE_DE_RAMA` y abrir PR hacia `develop`.
7. El owner valida CI y prueba el flujo. Fusiona conservando commits; avisa al siguiente compañero con fase, PR y estado. La preparación no envía estos avisos automáticamente.

Los cinco PR se integran en orden. Al final, PR `develop` → `main` y etiqueta de entrega si el owner la desea. No es necesario publicar APK en el repositorio: usar artefacto CI o archivo de entrega autorizado, sin claves.

## Evidencia de colaboración

```powershell
git log develop --format="%h | %an | %ae | %s" --no-merges
git shortlog -sne develop
```

Verificar cinco autores reales y contribuciones de cada uno. Una cuenta IA o bot no sustituye automáticamente la identificación requerida por el docente; el integrante debe conservar su autoría y explicar su módulo. Mantener enlaces a los cinco PR/commits en README final. No confundir el commit de preparación del owner con la implementación de su F02.
