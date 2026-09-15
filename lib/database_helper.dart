import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/tarefa.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();

  DatabaseHelper._init();

  Future<List<Tarefa>> queryAll() async {
    final prefs = await SharedPreferences.getInstance();

    final dados = prefs.getString('tarefas');

    if (dados == null || dados.isEmpty) {
      return [];
    }

    final List lista = jsonDecode(dados);

    return lista
        .map((item) => Tarefa.fromMap(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<int> insert(Tarefa tarefa) async {
    final tarefas = await queryAll();

    int novoId = 1;

    if (tarefas.isNotEmpty) {
      novoId = tarefas
              .map((t) => t.id ?? 0)
              .reduce((a, b) => a > b ? a : b) +
          1;
    }

    final novaTarefa = tarefa.copyWith(id: novoId);

    tarefas.insert(0, novaTarefa);

    await _salvar(tarefas);

    return novoId;
  }

  Future<int> update(Tarefa tarefa) async {
    final tarefas = await queryAll();

    final index = tarefas.indexWhere((t) => t.id == tarefa.id);

    if (index == -1) {
      return 0;
    }

    tarefas[index] = tarefa;

    await _salvar(tarefas);

    return 1;
  }

  Future<int> delete(int id) async {
    final tarefas = await queryAll();

    final quantidadeAntes = tarefas.length;

    tarefas.removeWhere((t) => t.id == id);

    await _salvar(tarefas);

    return quantidadeAntes - tarefas.length;
  }

  Future<void> _salvar(List<Tarefa> tarefas) async {
    final prefs = await SharedPreferences.getInstance();

    final dados = tarefas.map((t) => t.toMap()).toList();

    await prefs.setString('tarefas', jsonEncode(dados));
  }
}
