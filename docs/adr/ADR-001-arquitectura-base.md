# ADR-001 — Arquitectura base de SeguroMina

- **Fecha:** Módulo 1
- **Estado:** Aceptada
- **Ámbito:** MVP (5 escenarios, sin backend)

## Contexto

SeguroMina entrena identificación de peligros y evaluación IPERC en escenarios
mineros. El contenido educativo es el activo caro y frágil del producto; el
código es comparativamente simple. Las decisiones de arquitectura deben
proteger el contenido, no lucirse técnicamente.

Tres restricciones mandan sobre el resto:

1. La app se usa donde no hay conectividad confiable.
2. El contenido normativo cambia: el reglamento base ya lleva dos
   modificatorias y ediciones consolidadas periódicas.
3. Un especialista en seguridad minera debe poder auditar las reglas de
   evaluación sin leer código de interfaz.

## Decisiones

### 1. Sin backend en el MVP

Todo el contenido viaja empaquetado y todo el progreso se guarda en el
dispositivo.

Elimina de un golpe: servidor, autenticación, sincronización, costos de
operación, consentimiento de datos y latencia. No hay dato que compartir entre
dispositivos mientras no exista el panel docente.

**Descartado:** Firebase desde el día uno. Introduce dependencia de red en una
app que debe funcionar sin ella, y añade una superficie de datos personales
que el MVP no necesita.

**Consecuencia:** el panel docente de la Versión 2 requerirá diseñar el
backend desde cero. Se acepta: es preferible a construir infraestructura antes
de saber si los escenarios enseñan.

### 2. Contenido como datos versionados, no como código

Los escenarios son JSON en `assets/content/scenarios/`, validados contra un
esquema al cargarse. Las referencias normativas viven en
`NormativeSource`, con edición explícita.

Permite que el experto revise y corrija contenido sin tocar Dart, y que
agregar el escenario 6 sea agregar un archivo.

**Consecuencia:** hace falta validación de esquema en tiempo de carga, y un
JSON mal formado es un fallo de build, no un error de usuario.

### 3. Motor de evaluación en Dart puro

`lib/domain/risk_engine/` no importa Flutter. Un test de arquitectura
(`test/core/architecture_test.dart`) hace fallar el build si alguien lo hace.

Es la parte del sistema donde un error causa daño formativo: debe ser
auditable y tener cobertura cercana al total.

### 4. MVVM con Riverpod, no Clean Architecture completa

MVVM porque la pantalla de inspección mantiene estado complejo y de larga
duración. Riverpod porque la inyección de dependencias se verifica en
compilación y los providers se testean sin `WidgetTester`.

**Descartado:** capa de casos de uso obligatoria para cada operación. Con seis
features añade decenas de archivos sin beneficio. Los casos de uso se aplican
solo donde la lógica es densa: la evaluación de riesgo.

**Descartado:** BLoC. El boilerplate de eventos no se justifica para un equipo
pequeño.

### 5. Drift (SQLite) para el progreso

Los intentos son datos relacionales que hay que agregar por escenario y por
tipo de peligro para producir las métricas de aprendizaje del proyecto.

**Descartado:** Hive, por mal ajuste a consultas agregadas. Isar, por
incertidumbre sobre su mantenimiento a largo plazo — en un proyecto educativo
que debe durar años, eso pesa más que el rendimiento.

### 6. Textos externos desde el Módulo 1

Ninguna cadena visible se escribe dentro de un widget. Las traducciones quedan
fuera del MVP, pero la arquitectura de i18n entra ahora porque retrofitarla
después obliga a revisar cada pantalla.

### 7. Sin tipografías descargadas

No se usa `google_fonts`. Una app offline-first no puede depender de una
descarga en tiempo de ejecución para renderizar texto.

### 8. El color nunca es el único portador de información

El amarillo de marca (`#F4C430`) no alcanza contraste AA como color de texto
sobre blanco, así que se usa solo como superficie y acento. Los niveles de
riesgo llevan siempre etiqueta textual además del color, y se separan también
en luminancia. Ambas reglas están cubiertas por tests.

## Pendientes registrados

- El contenido educativo se marca `validado: false` hasta que un ingeniero de
  seguridad minera firme la revisión. La app muestra un aviso visible mientras
  tanto.
- Las referencias a artículos concretos del reglamento se contrastan contra la
  edición consolidada del MINEM antes de publicarse. Ninguna se escribe de
  memoria.
- El modo narrativo accesible para usuarios con discapacidad visual queda
  fuera del MVP y declarado como tal: la interacción núcleo es espacial y
  requiere un diseño alternativo, no un ajuste.
