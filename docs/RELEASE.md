# Publicación de SeguroMina

## 1. Generar el keystore

Este paso lo haces tú, una sola vez, en tu equipo. **Nadie más debe hacerlo por
ti**: quien tenga el keystore y su contraseña puede publicar actualizaciones
falsas de SeguroMina, y una clave filtrada no se puede revocar.

```bash
keytool -genkeypair -v -keystore seguromina-release.jks -storetype JKS -keyalg RSA -keysize 2048 -validity 10000 -alias seguromina
```

`keytool` viene con el JDK. En Windows suele estar en
`C:\Program Files\Java\jdk-17\bin\keytool.exe`, y también dentro de Android
Studio (`...\jbr\bin\keytool.exe`).

El comando te pedirá **dos contraseñas** (la del almacén y la de la clave;
puedes usar la misma) y unos datos de identidad. Anota el alias — aquí es
`seguromina`.

`-validity 10000` son unos 27 años. Google Play exige que la clave siga siendo
válida después de 2033, así que no bajes ese número.

> **Guarda el archivo `.jks` y sus contraseñas en un gestor de contraseñas o en
> un respaldo cifrado.** Si lo pierdes, no podrás volver a publicar una
> actualización de esta app: Android exige que todas las versiones estén
> firmadas con la misma clave. Tendrías que publicarla como una aplicación
> distinta y tus usuarios perderían el progreso guardado.

El `.gitignore` ya bloquea `*.jks`, `*.keystore` y `key.properties` para que un
`git add -A` no lo suba por accidente.

## 2. Convertir el keystore a texto

GitHub Secrets solo guarda texto, así que el archivo binario va en base64.

**Windows (PowerShell):**

```powershell
[Convert]::ToBase64String([IO.File]::ReadAllBytes("seguromina-release.jks")) | Set-Content -NoNewline keystore.b64
```

**Linux o macOS:**

```bash
base64 -w0 seguromina-release.jks > keystore.b64
```

## 3. Configurar los GitHub Secrets

En el repositorio: **Settings → Secrets and variables → Actions → New
repository secret**. Crea estos cuatro:

| Secret | Contenido |
|---|---|
| `ANDROID_KEYSTORE_BASE64` | Todo el contenido de `keystore.b64` |
| `ANDROID_KEYSTORE_PASSWORD` | La contraseña del almacén |
| `ANDROID_KEY_ALIAS` | `seguromina` |
| `ANDROID_KEY_PASSWORD` | La contraseña de la clave |

Borra `keystore.b64` cuando termines. El `.jks` guárdalo; el `.b64` es
desechable.

## 4. Publicar una versión

La versión sale de `pubspec.yaml` y de ningún otro sitio, para que el nombre
del archivo no pueda desviarse de lo que el APK declara por dentro:

```yaml
version: 0.1.0+1
#        ^^^^^ versionName   ^ versionCode
```

Sube `versionCode` en **cada** publicación: Android rechaza instalar un APK con
un `versionCode` igual o menor al ya instalado.

Después, crea la etiqueta:

```bash
git tag v0.1.0 && git push origin v0.1.0
```

Eso dispara el workflow, que compila en release, firma, verifica y adjunta
`SeguroMina-v0.1.0-release.apk` a una GitHub Release. En ramas normales el APK
sale solo como artefacto de Actions; en una etiqueta, si falta el keystore, el
build falla en vez de publicar algo sin firmar.

## 5. Sobre el bloqueo de Chrome

**Firmar el APK no quita el aviso de Chrome.** Conviene decirlo claro porque es
la causa habitual de perder tiempo: Safe Browsing avisa por la *reputación de
descarga* del archivo, no por su certificado. Un APK recién publicado es un
archivo que Chrome no ha visto nunca, y sobre esa base muestra
«no se descarga habitualmente y podría ser peligroso».

Lo que sí influye, de mayor a menor efecto:

| Medida | Efecto |
|---|---|
| Google Play (prueba interna) | Elimina el aviso por completo |
| Firebase App Distribution | Lo elimina: instala con su propia app |
| GitHub Release (URL HTTPS estable) | Lo reduce bastante; ya configurado |
| APK release firmado con clave propia | Necesario, pero no suficiente por sí solo |
| Descargar por HTTP en vez de HTTPS | Bloqueo seguro. Nunca repartas así |

Para repartir a estudiantes sin fricción, el camino corto es **Firebase App
Distribution** (gratuito, sin cuenta de desarrollador). El definitivo es la
**prueba interna de Google Play** (cuenta de 25 USD, pago único).

Si repartes el enlace de la Release, avisa a los estudiantes de que deben
permitir «Instalar apps desconocidas» para su navegador, y de que el aviso de
Chrome se acepta con **Descargar de todos modos**.

## 6. Antes de publicar en Google Play

- [ ] Cambiar `APP_ORG` en el workflow por tu dominio real. Ahora es
      `pe.seguromina`, que da el applicationId `pe.seguromina.seguromina`.
      **No se puede cambiar después de la primera subida a Play.**
- [ ] Generar el icono de lanzador definitivo — instrucciones en
      [assets/brand/README.md](../assets/brand/README.md).
- [ ] Subir `version` a `1.0.0+1` si consideras que la app está lista para
      llamarse 1.0.
- [ ] Revisar el estado de validación del contenido: hoy
      `ContentValidation.status` es `pendiente`, y la app lo declara al
      estudiante. Publicar material de seguridad minera sin revisión de un
      especialista es una decisión que conviene tomar a conciencia.
