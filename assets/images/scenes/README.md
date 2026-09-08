# Escenas

Ilustraciones vectoriales de los escenarios, en SVG.

Regla de produccion: las escenas no se dibujan una por una. Se construyen a
partir de una biblioteca compartida de componentes (sostenimiento, tuberia de
ventilacion, jumbo, personal, senalizacion, iluminacion, acumulacion de
material). La escena 5 debe costar aproximadamente la mitad que la escena 1.

Las zonas activas de cada peligro se definen en el JSON del escenario con
coordenadas relativas al viewBox del SVG, nunca en pixeles, para que la
interaccion funcione igual en telefono y en tablet.

Pendiente: definir el viewBox estandar y la guia de estilo antes de ilustrar
la primera escena.
