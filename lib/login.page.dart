import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:projeto_jwt/home.page.dart';
import 'dart:convert' show json, base64, ascii;



import 'main.dart';

class LoginPage extends StatelessWidget {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void displayDialog(BuildContext context, String title, String text) => 
    showDialog(
      context: context,
      builder: (context) =>
        AlertDialog(
          title: Text(title),
          content: Text(text)
        ),
    );

    Future<String> attemptLogIn(String username, String pass) async {
    var res = await http.post(
      "$SERVER_IP/auth/login",
      body: {
        "username": username,
        "pass": pass
      }
    );
    if(res.statusCode == 200) return res.body;
    return null;
  }

  Future<int> attemptSignUp(String username, String password) async {
    var res = await http.post(
      '$SERVER_IP/users',
      body: {
        "username": username,
        "password": password
      }
    );
    return res.statusCode;
    
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Log In"),),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: 'Username'
              ),
            ),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password'
              ),
            ),
            FlatButton(
              onPressed: () async {
                var username = _usernameController.text;
                var password = _passwordController.text;
                var jwt = await attemptLogIn(username, password);
                if(jwt != null) {
                  storage.write(key: "jwt", value: jwt);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HomePage.fromBase64(jwt)
                    )
                  );
                } else {
                  displayDialog(context, "Ocorreu um erro", "Nenhuma conta encontrada com esse usuário e senha");
                }
              },
              child: Text("Log In")
            ),
            FlatButton(
              onPressed: () async {
                var username = _usernameController.text;
                var password = _passwordController.text;

                if(username.length < 4) 
                  displayDialog(context, "Nome de usuário inválido", "O nome de usuário deve conter no mínimo 6 caracteres");
                else if(password.length < 6) 
                  displayDialog(context, "Senha de usuário inválido", "A senha de usuário deve conter no mmínimo 6 caracteres");
                else{
                  var res = await attemptSignUp(username, password);
                  if(res == 201)
                    displayDialog(context, "Sucesso", "O usuário foi criado. Entre agora.");
                  else if(res == 409)
                    displayDialog(context, "Este usuário já existe", "Por favor, tente novamente com outra conta");  
                  else {
                    displayDialog(context, "Erro", "Um erro desconhecido ocorreu.");
                  }
                }
              },
              child: Text("Sign Up")
            )
          ],
        ),
      )
    );
  }
}