import 'package:common/dio_client.dart';
import 'package:common/ui/loadingIndicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:passenger_app/src/services/place_service.dart';

class AddressSearch extends SearchDelegate<Suggestion?> {
  var recent = [
    // 'john do',
    // 'biology',
    // 'astro',
  ];
  List<Suggestion> result = [];

  final String sessionToken;
  AddressSearch(
    this.sessionToken,
  );

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
        close(context, null);
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
                  child: Icon(Icons.location_pin),
                ),
              ),
              title: Text("${result[index].description}"),
            ),
          )
        : loadResults(context);
  }

  Widget loadResults(BuildContext context) {
    return Consumer(builder: (context, ref, child) {
      return FutureBuilder(
          future: PlaceApiProvider(ref.read(dioClientProvider), sessionToken)
              .fetchSuggestions(query),
          builder: (ctx, snapshot) {
            if (snapshot.hasData) {
              result = snapshot.data as List<Suggestion>;
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
                          close(context, result[index]);
                        },
                        leading: AspectRatio(
                          aspectRatio: 1,
                          child: Container(
                            child: Icon(Icons.location_pin),
                          ),
                        ),
                        title: Text("${result[index].description}"),
                      ),
                    );
            } else if (snapshot.hasError) {
              return Center(
                  child: Text(
                "Error loading the results",
                style: Theme.of(context).textTheme.headline6,
              ));
            }
            return loadingIndicator;
          });
    });
  }
}
