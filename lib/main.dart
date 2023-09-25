import 'package:flutter/material.dart';

void main() {
  runApp(NoteApp());
}

class NoteApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bloco de Notas com Login',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginScreen(),
    );
  }
}

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  final String testUsername = 'usuario1';
  final String testPassword = 'senha1';

  void _login() {
    String enteredUsername = _usernameController.text;
    String enteredPassword = _passwordController.text;

    if (enteredUsername == testUsername && enteredPassword == testPassword) {
      // Login bem-sucedido
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => NoteListScreen()),
      );
    } else {
      // Login falhou
      _showMessage('Login falhou. Verifique o nome de usuário e senha.');
    }
  }

  void _showMessage(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Mensagem'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Fechar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tela de Login'),
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Nome de Usuário',
                ),
              ),
              SizedBox(height: 16.0),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Senha',
                ),
              ),
              SizedBox(height: 24.0),
              ElevatedButton(
                onPressed: _login,
                child: Text('Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class NoteListScreen extends StatefulWidget {
  @override
  _NoteListScreenState createState() => _NoteListScreenState();
}

class _NoteListScreenState extends State<NoteListScreen> {
  List<Note> _notes = [];
  TextEditingController _titleController = TextEditingController();
  TextEditingController _noteController = TextEditingController();
  int? _selectedIndex;
  String _searchTerm = ''; // Termo de pesquisa

  @override
  Widget build(BuildContext context) {
    // Função para filtrar as notas com base no termo de pesquisa
    List<Note> filteredNotes = _notes.where((note) {
      final title = note.title.toLowerCase();
      return title.contains(_searchTerm.toLowerCase());
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Bloco de Notas com Títulos'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              // Logout do usuário
              Navigator.pop(context); // Retorna à tela de login
            },
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          // Barra de pesquisa
          Padding(
            padding: EdgeInsets.all(16.0),
            child: TextField(
              onChanged: (value) {
                // Atualizar o termo de pesquisa quando o texto mudar
                setState(() {
                  _searchTerm = value;
                });
              },
              decoration: InputDecoration(
                labelText: 'Pesquisar por título',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredNotes.length,
              itemBuilder: (context, index) {
                return Card(
                  child: ListTile(
                    title: Text(
                      '${filteredNotes[index].title} - ${_formatDateTime(filteredNotes[index].dateTime)}',
                      style: TextStyle(
                        backgroundColor: filteredNotes[index].isHighlighted ? Colors.yellow : Colors.transparent,
                      ),
                    ),
                    onTap: () {
                      _showNoteContent(filteredNotes[index]);
                    },
                    onLongPress: () {
                      _editOrDeleteNoteDialog(filteredNotes[index]);
                    },
                  ),
                );
              },
            ),
          ),
          Divider(),
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: 'Título da nota',
                  ),
                ),
                SizedBox(height: 8.0),
                TextField(
                  controller: _noteController,
                  decoration: InputDecoration(
                    labelText: 'Digite sua nota',
                  ),
                  maxLines: null, // Varias linhas
                ),
                SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: () {
                    final title = _titleController.text;
                    final content = _noteController.text;
                    if (title.isNotEmpty && content.isNotEmpty) {
                      setState(() {
                        if (_selectedIndex != null) {
                          // Editar a nota existente
                          _updateNote(_selectedIndex!, title, content);
                          _selectedIndex = null;
                        } else {
                          // Adicionar uma nova nota
                          _addNote(title, content);
                        }
                        _titleController.clear();
                        _noteController.clear();
                      });
                    }
                  },
                  child: Text(_selectedIndex != null ? 'Salvar Edições' : 'Salvar Nota'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute}';
  }

  void _editOrDeleteNoteDialog(Note note) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Opções da Nota'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Fechar o diálogo
                _editNote(note);
              },
              child: Text('Editar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Fechar o diálogo
                _deleteNote(note);
              },
              child: Text('Excluir'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Fechar o diálogo
                if (note.isHighlighted) {
                  // Se a nota estiver marcada, desmarque-a
                  _unhighlightNote(note);
                } else {
                  // Caso contrário, marque-a
                  _highlightNote(note);
                }
              },
              child: Text(note.isHighlighted ? 'Remover Marcação' : 'Marcar em Amarelo'),
            ),
          ],
        );
      },
    );
  }

  void _removeNote(Note note) {
    setState(() {
      _notes.remove(note);
    });
  }

  void _showNoteContent(Note note) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(note.title),
          content: Text(note.content),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Fechar'),
            ),
          ],
        );
      },
    );
  }

  void _editNote(Note note) {
    // Preencher os campos de edição com os valores da nota selecionada
    _titleController.text = note.title;
    _noteController.text = note.content;
    setState(() {
      _selectedIndex = _notes.indexOf(note);
    });
  }

  void _addNote(String title, String content) {
    final now = DateTime.now();
    setState(() {
      _notes.add(Note(title, content, now));
    });
  }

  void _updateNote(int index, String title, String content) {
    setState(() {
      _notes[index].title = title;
      _notes[index].content = content;
    });
  }

  void _deleteNote(Note note) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmar Exclusão'),
          content: Text('Tem certeza de que deseja excluir esta nota?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Fechar o diálogo de confirmação
              },
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Fechar o diálogo de confirmação
                _removeNote(note);
              },
              child: Text('Confirmar'),
            ),
          ],
        );
      },
    );
  }

  void _highlightNote(Note note) {
    setState(() {
      note.isHighlighted = true;
    });
  }

  void _unhighlightNote(Note note) {
    setState(() {
      note.isHighlighted = false;
    });
  }
}

class Note {
  String title;
  String content;
  DateTime dateTime;
  bool isHighlighted;

  Note(this.title, this.content, this.dateTime, {this.isHighlighted = false});
}
