# React Native / Expo

> Conocimiento acumulado sobre Expo SDK 56.

## Errores Conocidos
| Error | Fix |
|-------|-----|
| `absoluteFillObject` | Usar `absoluteFill` de StyleSheet |
| Tab bar notch | `useSafeAreaInsets()` + paddingBottom |
| SplashScreen | `preventAutoHideAsync` antes de renderizar |

## Estándares
- `useSafeAreaInsets()` en todas las pantallas
- `android.statusBar.translucent: false`

## Ver También
- [[../proyectos/titan-mode\|Titan Mode]] — usa Expo SDK 56
- [[../conocimiento/ciberseguridad\|Ciberseguridad]] — checklist móvil
