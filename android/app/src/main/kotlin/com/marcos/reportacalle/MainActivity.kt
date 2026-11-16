// Paquete de Android de la app (es como su "dirección" única en el teléfono)
package com.marcos.reportacalle

// FlutterFragmentActivity en vez de FlutterActivity: el paquete local_auth
// (la huella) la necesita porque la ventanita de Android es un "Fragment"
import io.flutter.embedding.android.FlutterFragmentActivity

// La ventana principal de Android. No tiene nada más porque toda la app
// está hecha en Flutter (carpeta lib/), esto solo la "hospeda"
class MainActivity : FlutterFragmentActivity()
