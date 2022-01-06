import 'package:booklis/models/book.dart';
import 'package:booklis/models/active_book.dart';
import 'package:booklis/provider/reading_goal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class NewActiveBookForm extends StatefulWidget {
  const NewActiveBookForm({Key? key}) : super(key: key);

  @override
  _NewActiveBookFormState createState() => _NewActiveBookFormState();
}

class _NewActiveBookFormState extends State<NewActiveBookForm> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _pagesController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _pagesController.dispose();
    super.dispose();
  }

  String? _titleValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Tittelen kan ikke være tom';
    }
    return null;
  }

  String? _pagesValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Antall sider må være mer enn 0';
    } else if (int.tryParse(value) == null) {
      return 'Antall sider må være et tall';
    }
    return null;
  }

  void _handleNewBookPressed() {
    if (_formKey.currentState!.validate()) {
      ActiveBook newActiveBook = ActiveBook(
        book: Book(
          name: _titleController.text,
          pages: int.parse(_pagesController.text),
        ),
        pagesRead: 0,
        startDate: DateTime.now(),
      );

      Provider.of<GoalModel>(context, listen: false)
          .addActiveBook(newActiveBook);

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Text(
                  'Ny bok:',
                  style: Theme.of(context).textTheme.headline4,
                ),
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(hintText: 'Tittel'),
                  validator: _titleValidator,
                ),
                TextFormField(
                  controller: _pagesController,
                  decoration: const InputDecoration(hintText: 'Antall sider'),
                  validator: _pagesValidator,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: ElevatedButton(
                    onPressed: _handleNewBookPressed,
                    child: const Text('Legg til'),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
