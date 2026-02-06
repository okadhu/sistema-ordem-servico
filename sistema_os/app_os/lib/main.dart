import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/providers/auth_provider.dart';
import 'core/providers/orders_provider.dart';

import 'modules/login/login_page.dart';
import 'modules/dashboard/dashboard_page.dart';
import 'modules/orders/list/list_orders_page.dart';
import 'modules/orders/create/create_order_page.dart';
import 'modules/orders/details/order_details_page.dart';
import 'modules/orders/gestor/gestor_dashboard_page.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryGreen = Color(0xFF00FF88);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => OrdersProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: "Sistema OS",

        // 🌑🔥 TEMA PRETO COM VERDE PRINCIPAL
        theme: ThemeData.dark().copyWith(
          scaffoldBackgroundColor: Colors.black,
          primaryColor: primaryGreen,
          colorScheme: const ColorScheme.dark(
            primary: primaryGreen,
            secondary: primaryGreen,
          ),

          // APPBAR
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.black,
            foregroundColor: Color(0xFF00FF88),
            elevation: 2,
          ),

          // BOTÕES
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryGreen,
              foregroundColor: Colors.black,
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
            ),
          ),

          // CAMPOS DE TEXTO
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.grey.shade900,
            focusColor: primaryGreen,
            labelStyle: const TextStyle(color: primaryGreen),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: primaryGreen, width: 2),
              borderRadius: BorderRadius.circular(12),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),

        initialRoute: "/login",
        routes: {
          "/login": (_) => const LoginPage(),
          "/dashboard": (_) => const DashboardPage(),
          "/orders": (_) => const ListOrdersPage(),
          "/create_order": (_) => const CreateOrderPage(),
           "/gestor_dashboard": (context) => const GestorDashboardPage(),
          // 🔥 ROTA CORRIGIDA COM RECEBIMENTO DE ARGUMENTO
          "/order_details": (context) {
            final orderId = ModalRoute.of(context)!.settings.arguments as int;
            return OrderDetailsPage(orderId: orderId);
          },
        },
      ),
    );
  }
}
