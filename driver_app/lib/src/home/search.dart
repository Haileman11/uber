import 'package:flutter/material.dart';

class DataSearch extends SearchDelegate<String> {
  var recent = [
    // 'john do',
    // 'biology',
    // 'astro',
  ];
  var result = [];
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, "");
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    FocusScope.of(context).unfocus();

    return loadResults(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    var suggestions = [];
    return query.isEmpty
        ? ListView.builder(
            itemCount: suggestions.length,
            itemBuilder: (ctx, index) => ListTile(
              leading: AspectRatio(
                aspectRatio: 1,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey, width: 0.5),
                    image: DecorationImage(
                      fit: BoxFit.fill,
                      image: NetworkImage(
                        result[index].profilePicture,
                      ),
                    ),
                  ),
                ),
              ),
              title:
                  Text("${result[index].firstName} ${result[index].lastName}"),
              subtitle: Text(result[index].headline),
            ),
          )
        : loadResults(context);
  }

  Widget loadResults(BuildContext context) {
    return FutureBuilder(
        future: Future.delayed(Duration(seconds: 1)),
        builder: (ctx, snapshot) {
          if (snapshot.hasData) {
            result = snapshot.data as List;
            return result.isEmpty
                ? Center(
                    child: Text(
                    "No results",
                    style: Theme.of(context).textTheme.headline6,
                  ))
                : ListView.builder(
                    itemCount: result.length,
                    itemBuilder: (ctx, index) => ListTile(
                      onTap: () {
                        print("selected result");
                      },
                      leading: AspectRatio(
                        aspectRatio: 1,
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.grey, width: 0.5),
                            image: DecorationImage(
                              fit: BoxFit.fill,
                              image: NetworkImage(
                                result[index].profilePicture,
                              ),
                            ),
                          ),
                        ),
                      ),
                      title: Text(
                          "${result[index].firstName} ${result[index].lastName}"),
                      subtitle: Text(result[index].headline),
                    ),
                  );
          } else if (snapshot.hasError) {
            return Center(
                child: Text(
              "Error loading the results",
              style: Theme.of(context).textTheme.headline6,
            ));
          }
          return CircularProgressIndicator();
        });
  }
}
