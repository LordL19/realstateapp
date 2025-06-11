import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:provider/provider.dart';
import 'package:realestate_app/viewmodels/property_viewmodel.dart';
import 'package:realestate_app/views/profile_view.dart';
import 'package:realestate_app/views/properties/my_properties_list_view.dart';
import 'package:realestate_app/views/properties/property_list_view.dart';

class MainTabView extends StatelessWidget {
  const MainTabView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final client = GraphQLProvider.of(context).value;
    return ChangeNotifierProvider(
      create: (context) => PropertyViewModel(client: client)..fetchProperties(),
      child: const _MainTabViewContent(),
    );
  }
}

class _MainTabViewContent extends StatefulWidget {
  const _MainTabViewContent({Key? key}) : super(key: key);

  @override
  _MainTabViewContentState createState() => _MainTabViewContentState();
}

class _MainTabViewContentState extends State<_MainTabViewContent> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    PropertyListView(),
    MyPropertiesListView(),
    ProfileView(),
  ];

  void _onItemTapped(int index) {
    // Si el usuario va a la pestaña "Mis Propiedades" y aún no se han cargado,
    // iniciamos la carga.
    if (index == 1 &&
        context.read<PropertyViewModel>().myPropertiesState ==
            PropertyState.initial) {
      context.read<PropertyViewModel>().fetchMyProperties();
    }
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _widgetOptions,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Propiedades',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.business),
            label: 'Mis Propiedades',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
} 