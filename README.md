# SeguroMina

Entrenador móvil de identificación de peligros y evaluación IPERC para
estudiantes de Ingeniería de Minas.

El estudiante entra a un escenario minero, inspecciona la escena, marca los
peligros que ve, los evalúa con la matriz del reglamento, elige controles y
ve las consecuencias de sus decisiones. Funciona sin conexión.

> **Contenido en revisión.** Los escenarios de esta versión no han sido
> validados por un especialista en seguridad minera. Sirven como práctica
> académica, no como referencia normativa. La app muestra este aviso al
> usuario mientras siga vigente.

## Estado

**Módulo 1 de 15 — configuración del proyecto y arquitectura base.**

Completado en este módulo:

- [x] Estructura de carpetas por capas y por feature
- [x] Sistema de tema claro y oscuro con tokens de color y tipografía
- [x] Escalado de texto combinado con el ajuste del sistema
- [x] Carga de textos externos en JSON (sin cadenas dentro de widgets)
- [x] Tipo `Result` y jerarquía de fallos
- [x] Trazabilidad de la fuente normativa y aviso de contenido no validado
- [x] Tests de contraste, textos y arquitectura
- [x] CI en GitHub Actions: formato, análisis, pruebas y APK

Siguiente: Módulo 2 — navegación y routing.

## Requisitos

- Flutter 3.27 o superior (canal stable)
- Dart 3.4 o superior

## Instalación

```bash
git clone <url-del-repositorio>
cd seguromina
flutter pub get
flutter run
```

El repositorio no versiona las carpetas de plataforma (`android/`, `ios/`).
Se generan cuando hacen falta:

```bash
flutter create --platforms=android .
flutter build apk --debug
```

## Verificación

```bash
dart format lib test
flutter analyze --fatal-infos
flutter test
```

Los tres comandos corren igual en CI. Un cambio que no pase localmente no
pasará en el pipeline.

## Estructura

```
lib/
├── main.dart                  Punto de entrada
├── app.dart                   Widget raíz, tema y escalado de texto
├── core/                      Transversal a toda la app
│   ├── theme/                 Colores, tipografía, espaciado, temas
│   ├── constants/             Constantes y fuente normativa
│   ├── errors/                Result y jerarquía de fallos
│   ├── l10n/                  Carga de textos externos
│   └── settings/              Apariencia y accesibilidad
├── domain/
│   └── risk_engine/           Motor de evaluación IPERC — Dart puro
├── data/
│   ├── content/               Lectura y validación de escenarios
│   └── local/                 Base de datos de progreso
└── features/
    ├── home/                  Entrada (provisional)
    ├── scenarios/             Catálogo de escenarios
    ├── inspection/            Escena con zonas activas
    ├── iperc/                 Matriz de evaluación y controles
    ├── feedback/              Consecuencia y debrief
    ├── progress/              Historial y evolución
    └── profile/               Perfil local del estudiante

assets/
├── i18n/                      Textos de interfaz por idioma
├── content/scenarios/         Escenarios en JSON
└── images/scenes/             Escenas vectoriales (SVG)

docs/adr/                      Decisiones de arquitectura registradas
```

### Reglas que el código hace cumplir

- `lib/domain/` no puede importar Flutter. Hay un test que lo verifica.
- Ninguna cadena visible se escribe dentro de un widget: van en
  `assets/i18n/es.json`.
- El amarillo `#F4C430` no se usa como color de texto sobre fondo claro. No
  alcanza contraste AA y hay un test que lo documenta.
- Los niveles de riesgo siempre llevan etiqueta textual además de color.

## Fuente normativa

D.S. N.° 024-2016-EM, modificado por D.S. N.° 023-2017-EM y D.S. N.°
034-2023-EM. Edición consolidada 2026 del Ministerio de Energía y Minas.

Cada referencia normativa mostrada al estudiante lleva su edición. El
reglamento se modifica periódicamente y una cita desactualizada enseña mal.

## Alcance del MVP

Incluye: 5 escenarios, inspección de escena, clasificación de peligros, matriz
IPERC, selección de controles con riesgo residual, consecuencia simulada,
debrief y progreso local. Español, sin conexión, sin cuenta de usuario.

Fuera del MVP: backend, panel docente, exportación de reportes, inglés y
quechua, insignias y tabla de posiciones, IA, realidad aumentada, 3D.

## Licencia

Por definir.
