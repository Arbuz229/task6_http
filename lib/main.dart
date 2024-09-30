import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

Future<Album> fetchAlbum() async {
  final response = await http.get(Uri.parse('https://catfact.ninja/fact'));

  if (response.statusCode == 200) {
    return Album.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  } else {
    throw Exception('Failed to load album');
  }
}

class Album {
  final String fact;
  final int length;

  const Album({
    required this.fact,
    required this.length,
  });

  factory Album.fromJson(Map<String, dynamic> json) {
    return switch (json) {
      {
        'fact': String fact,
        'length': int length,
      } =>
        Album(
          length: length,
          fact: fact,
        ),
      _ => throw const FormatException('Failed to load album.'),
    };
  }
}

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Future<Album> futureAlbum;

  @override
  void initState() {
    super.initState();
    futureAlbum = fetchAlbum();
  }

  void _refresh() {
    setState(() {
      futureAlbum = fetchAlbum();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Random facts about cats',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.black12),
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Random facts about cats'),
        ),
        body: Center(
          child: FutureBuilder<Album>(
            future: futureAlbum,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Error: ${snapshot.error}'),
                    ElevatedButton(
                      onPressed: _refresh,
                      child: const Text('Retry'),
                    ),
                  ],
                );
              } else if (snapshot.hasData) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(snapshot.data!.fact, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _refresh,
                      child: const Text('Get Another Fact', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
                    ),
                  ],
                );
              }
              return const SizedBox.shrink(); 
            },
          ),
        ),
      ),
    );
  }
}