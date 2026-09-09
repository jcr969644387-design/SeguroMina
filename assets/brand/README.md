# Marca SeguroMina

## Concepto

Un **escudo** (protección) que contiene un **casco minero** cuya **lámpara**
hace de **ojo de inspección**, sobre un **check** (la decisión validada).

La silueta es angular y vertical de forma deliberada. ProfVent usa un símbolo
circular y radial de ventilación; una marca redonda aquí haría que las dos
aplicaciones se leyeran como el mismo producto en la bandeja de iconos.

## Archivos

| Archivo | Uso |
|---|---|
| `seguromina_logo.svg` | Icono de aplicación, ficha de Google Play, documentos |
| `seguromina_logo_mono.svg` | Capa monocroma del icono adaptativo (Android 13+), una tinta |

El mismo trazado está replicado en `lib/core/brand/seguromina_mark.dart` como
`CustomPainter`, que es lo que se dibuja dentro de la app. Si se cambia la
geometría hay que cambiar **los dos**.

## Contraste

Las decisiones de color están medidas, no elegidas a ojo (WCAG 1.4.11 pide
3:1 para elementos gráficos):

| Par | Contraste | |
|---|---|---|
| Casco `#F4C430` sobre escudo `#2E5C8A` | 4.24:1 | cumple |
| Check blanco sobre escudo | 6.97:1 | cumple |
| Lámpara `#2C3E50` sobre casco | 6.69:1 | cumple |
| Escudo sobre fondo oscuro `#1A1A1A` | 2.50:1 | **no cumple** |

Por eso `SeguroMinaMark` acepta `onDark: true`, que añade un filete claro
alrededor del escudo (15:1 contra el fondo). Se descartó usar el azul claro
`#6B9BC9` en modo oscuro: el casco amarillo cae a 1.79:1 sobre él.

El check es blanco y no verde por la misma razón: el verde de marca sobre el
azul del escudo da 2.43:1.

## Icono de aplicación

La carpeta `android/` **no está versionada** — el CI la regenera con
`flutter create --platforms=android .` en cada build. Por eso el icono de
lanzador no se puede commitear como recurso nativo todavía.

Para generarlo cuando se fije la plataforma, añadir a `dev_dependencies`:

```yaml
flutter_launcher_icons: ^0.13.1
```

y la configuración:

```yaml
flutter_launcher_icons:
  android: true
  ios: true
  image_path: "assets/brand/icon_1024.png"
  adaptive_icon_background: "#2E5C8A"
  adaptive_icon_foreground: "assets/brand/icon_foreground.png"
  adaptive_icon_monochrome: "assets/brand/icon_mono.png"
```

Los PNG se exportan desde los SVG de esta carpeta a 1024x1024. En el icono
adaptativo, el contenido debe caber en el 66 % central del lienzo: exportar el
escudo al 66 % sobre fondo transparente, no el SVG completo.
