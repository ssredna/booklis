# Booklis

A Flutter app for managing my reading goal for 2022. 

<img src="https://drive.google.com/uc?export=view&id=12Ftk4zFNWA-0Xc7n7myHYlOHyHeTvZnq" width="400"/> <img src="https://drive.google.com/uc?export=view&id=1KkDIVk41V7RvCtvI0Q7VPj-119VMipl3" width="400"/> 

## Installation

If you want to install this app you can find the .apk file inside `build/app/outputs/apk/release/app-release.apk`. Just for Android as of now. 

## Technologies used

As this is a fairly simple project to learn the fundamentals and basics of Flutter, I tried to keep things simple, and not use too many third party dependencies. Below is an overview of some of the major technologies I used. 

### State Management

For state management I read the [Simple app state management](https://docs.flutter.dev/development/data-and-backend/state-mgmt/simple) guide written by the Flutter team, and decided to use [Provider](https://pub.dev/packages/provider). For this application I use only one model with all the state in it. 

#### Getters

This model exposes different parts of the model - with getters - for the widgets to listen to. 

E.g. I have a private list of the active books in the model

```dart
List<ActiveBook> _activeBooks = [];
```

This list is exposed with a getter as an UnmodifiableListView

```dart
UnmodifiableListView<ActiveBook> get activeBooks => UnmodifiableListView(_activeBooks);
```

Now the widget that lists the active books just have to listen to this field. Whenever it gets notified of a change, it rebuilds the widget with the new list.

A more complicated example is pagesPerDay, which is the amount of pages per day I will have to read to make the goal I set for 2022. This is not reflected in a private field, but needs to be computed based on how many books I already have read, and how far I've gotten in the books I'm currently reading. The getter for pagesPerDay computes this:

```dart
int get pagesPerDay => _calculatePagesPerDay();

int _calculatePagesPerDay() {
  int totalPagesToRead = _totalPagesToRead();
  int daysUntilDeadline = daysBetween(DateTime.now(), _deadline);
  return (totalPagesToRead / daysUntilDeadline).ceil();
}
```

Here `_totalPagesToRead()` uses `_activeBooks` and `_readBooks` along with the number of books that is the goal to calculate how many pages there are left to read. 

A widget can now listen to `pagesPerDay`, and whenever a change occurs that effects this field, it is recalculated. If the new value is different than the last, the widget is rebuilt (but only if the value actually has changed).

#### Changing state

To change the state in the model there are a couple of public methods. 

E.g. to add a new active book:

```dart
void addActiveBook(ActiveBook activeBook) {
  _activeBooks = [..._activeBooks, activeBook];

  notifyListeners();
}
```

The `notifyListeners()` method is the one who actually tells all the widgets that are listening to the model that there has been changes. Without this, the widgets would not know that there was changes, and would not rebuild with the new value. 

#### Provide

To actually be able to listen to the model inside the widget-tree, the model have to be provided. This needs to be above all the widgets that are going to listen to the model. For me, this meant above `MaterialApp`, since I listen to the model in a popup window as well. 

```dart
ChangeNotifierProvider(
  create: (context) => GoalModel(),
  child: MaterialApp(...),
)
```

#### Consume

Since I decided to use one model for all the state, I didn't want a widget who listens to the model as a whole. This would mean it would rebuild for every single change in the model, but I only want rebuilds on relevant changes. Therefore I did not use the [Consumer](https://pub.dev/documentation/provider/latest/provider/Consumer-class.html) widget, but the [Selector](https://pub.dev/documentation/provider/latest/provider/Selector-class.html), as this can listen to part of a model.

```dart
Selector<GoalModel, int>(
  selector: (context, goalModel) => goalModel.pagesLeftToday,
  builder: (context, pagesLeftToday, child) => InfoHeader(
    pagesLeftToday: pagesLeftToday,
  ),
)
```

Here I specify which model and the type of the field to listen to. I have to specify a selector method to retrieve the field, and a builder where I can use the field. 

As stated in the getters section, this builder will only rebuild if the value retrieved from the selector is changed. Which means if there has been a change in the model which caused the `pagesLeftToday` to be recalculated, but it still is the same value, then `InfoHeader` would not be rebuilt.

### Data persistence

Again, since this is a relatively simple project to learn the basics of Flutter development, I decided to use [shared_preferences](https://pub.dev/packages/shared_preferences). This is a simple key-value store for persistent data, which is very easy to set up and use. 

In my app it is tightly coupled with the state-model, which probably isn't optimal for future improvements (e.g. if I wan't to add firestore integration), but works fine for this simple app for now. 

#### Initializing

The model has an instance of the SharedPreferences, which is initialized at construction.

```dart
late final SharedPreferences _prefs;
bool _isLoaded = false;

GoalModel() {
  _loadPrefs();
}

Future<void> _loadPrefs() async {
  await _initPrefs();
  _getPrefItems();
  _isLoaded = true;
  notifyListeners();
}

Future<void> _initPrefs() async {
  _prefs = await SharedPreferences.getInstance();
}
```

Since the `.getInstance()` returns a `Future`, I decided to initialize using an async init method inside the constructor of the model. This way I didn't have to relate to the `_prefs` object as a `Future` the whole time, but instead just let it load before I use the model. 

The `_loadPrefs()` method also retrieves data from the `shared_preferences` store, before setting `isLoaded = true`, and notifying listening widgets of the change with `notifyListener()`. 

To make sure no-one listens to the model before the data is loaded, I listen to this `isLoaded` field above all other listeners, and only show the rest of the app when it has been set to true.

```dart
Selector<GoalModel, bool>(
  selector: (context, goalModel) => goalModel.isLoaded,
  builder: (context, isLoaded, child) {
    return isLoaded
        ? const DashBoard()
        : const Center(child: CircularProgressIndicator());
  },
)
```

#### Writing

Although `shared_preferences` is simple and easy to use, it is a bit limited in what kind of data it can store natively. This meant that for me to be able to store custom objects, like an `ActiveBook`, I had to create custom serialization methods to turn them into json-objects, so they could be stored as strings. 

```dart
class ActiveBook {
  Book book;
  int _pagesRead;
  DateTime startDate;

  Map<String, dynamic> toJson() => {
      'book': book.toJson(),
      'pagesRead': pagesRead,
      'startDate': startDate.toString(),
    };
}
```

When I had this method, is was simple to turn a list of active books into a string, and store that string.

```dart
_prefs.setString('activeBooks', jsonEncode(_activeBooks));
```

#### Reading

Since I had to store the objects as strings, I also had to be able to recreate the objects from the json strings. This again meant custom methods to handle this. 

```dart
class ActiveBook {
  Book book;
  int _pagesRead;
  DateTime startDate;

  factory ActiveBook.fromJson(Map<String, dynamic> json) => ActiveBook(
      book: Book.fromJson(json['book']),
      pagesRead: json['pagesRead'],
      startDate: DateTime.parse(json['startDate']),
    );
  
  static List<ActiveBook> decode(String activeBooksString) =>
    (jsonDecode(activeBooksString) as List<dynamic>)
        .map((map) => ActiveBook.fromJson(map))
        .toList();
}
```

I also added a static decode method, to make it easier to get the entire list of books from the string. 

## Future

There is no certain future for this app. I created this mainly as a project to learn the basics of Flutter, but at the same time it is an app that I'm planning to use this year to track my reading goal. This means I'll probably discover areas of improvement, and I'll just have to see if the areas are annoying enough, or I'm motivated enough to actually make the improvements. 

That being said, there are already areas in which I definately can see room for improvements, and I can also imagine it being restructured into a more bookshelf kind of app than just a reading goal. 

Things to work on, in no specific order:

- Specify your own reading goal (not just the hardcoded 14 books during 2022 as it is now).
- Edit books. Now, if a book is added, there is no way of either deleting or editing, so you better be certain once you press that add-button. This also means that if you add books retrospectively, the reading dates will be wrong. 
- A page for more detailed information about the goal. E.g. when you press the `InfoHeader` it takes you to this other page. Maybe also add editing opportunities here.
- Another list of books you want to read. Then they could have a "start" button, which moves it into the active books list. 
- Store the data in the cloud using e.g. firebase. 