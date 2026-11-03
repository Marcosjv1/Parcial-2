import 'dart:io';

import 'package:flutter/material.dart';

import '../database/db_helper.dart';
import '../models/entrada.dart';

// Pantalla principal: muestra la lista de entradas del diario
class InicioScreen extends StatefulWidget {
  const InicioScreen({super.key});

  @override
  State<InicioScreen> createState() => _InicioScreenState();
}

class _InicioScreenState extends State<InicioScreen> {
  // Aquí guardamos la "promesa" de las entradas que vienen de SQLite
  late Future<List<Entrada>> _entradas;

  @override
  void initState() {
    super.initState();
    _entradas = DBHelper.obtenerTodas();
  }

  // Vuelve a leer la base de datos y redibuja la lista
  void _recargar() {
    setState(() {
      _entradas = DBHelper.obtenerTodas();
    });
  }

  Future<void> _irANuevaEntrada() async {
    // Esperamos a que el usuario regrese del formulario y recargamos
    await Navigator.pushNamed(context, '/nueva');
    _recargar();
  }

  Future<void> _irADetalle(Entrada entrada) async {
    // Mandamos la entrada como argumento a la pantalla de detalle
    await Navigator.pushNamed(context, '/detalle', arguments: entrada);
    _recargar();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mi Bitácora')),
      drawer: _menuLateral(),
      floatingActionButton: FloatingActionButton(
        onPressed: _irANuevaEntrada,
        child: const Icon(Icons.add),
      ),
      // FutureBuilder: muestra algo distinto mientras carga, si hay error
      // o cuando ya llegaron los datos
      body: FutureBuilder<List<Entrada>>(
        future: _entradas,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error al cargar: ${snapshot.error}'));
          }

          final entradas = snapshot.data ?? [];
          if (entradas.isEmpty) {
            return const Center(
              child: Text(
                'Aún no tienes entradas.\nToca el botón + para agregar una.',
                textAlign: TextAlign.center,
              ),
            );
          }

          return ListView.builder(
            itemCount: entradas.length,
            itemBuilder: (context, i) {
              final entrada = entradas[i];
              return Card(
                child: ListTile(
                  // Hero: la foto "vuela" a la pantalla de detalle
                  leading: Hero(
                    tag: 'foto${entrada.id}',
                    child: _miniatura(entrada),
                  ),
                  title: Text(entrada.titulo),
                  subtitle: Text(entrada.fecha),
                  trailing: entrada.latitud != null
                      ? const Icon(Icons.location_on)
                      : null,
                  onTap: () => _irADetalle(entrada),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // Foto pequeña de la entrada (o un ícono si no tiene foto)
  Widget _miniatura(Entrada entrada) {
    if (entrada.imagen == null) {
      return const SizedBox(width: 56, height: 56, child: Icon(Icons.book));
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.file(
        File(entrada.imagen!),
        width: 56,
        height: 56,
        fit: BoxFit.cover,
      ),
    );
  }

  // Menú lateral (Drawer)
  Widget _menuLateral() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.teal),
            child: Text(
              'Bitácora\nMi diario personal',
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Inicio'),
            onTap: () => Navigator.pop(context), // solo cierra el menú
          ),
          ListTile(
            leading: const Icon(Icons.add),
            title: const Text('Nueva entrada'),
            onTap: () {
              Navigator.pop(context);
              _irANuevaEntrada();
            },
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('Acerca de'),
            onTap: () {
              Navigator.pop(context);
              showAboutDialog(
                context: context,
                applicationName: 'Bitácora',
                applicationVersion: '1.0',
                children: const [
                  Text('Diario personal con fotos, dictado por voz y GPS.'),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
