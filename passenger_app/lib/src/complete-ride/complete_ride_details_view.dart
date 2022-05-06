import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:passenger_app/src/booked-ride/booked_ride.dart';
import 'package:passenger_app/src/booked-ride/booked_ride_controller.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

/// Displays detailed information about a SampleItem.
class CompleteRideDetailsView extends ConsumerStatefulWidget {
  final BookedRide completeRide;

  const CompleteRideDetailsView(this.completeRide, {Key? key})
      : super(key: key);

  static const routeName = '/booking';

  @override
  ConsumerState<CompleteRideDetailsView> createState() =>
      _CompleteRideDetailsViewState();
}

class _CompleteRideDetailsViewState
    extends ConsumerState<CompleteRideDetailsView> {
  @override
  Widget build(BuildContext context) {
    BookedRide completeRide = widget.completeRide;
    return Scaffold(
        body: Center(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const SizedBox(
              height: 10.0,
            ),
            Container(
              padding: const EdgeInsets.all(8.0),
              constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.4),
              child: Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    const SizedBox(
                      height: 10.0,
                    ),
                    Column(
                      children: [
                        Center(
                            child: Text(
                          "You have reached your destination",
                          style: Theme.of(context).textTheme.titleLarge,
                        )),
                        SizedBox(
                          height: 15.0,
                        ),
                        Card(
                          child: ListTile(
                            leading: Text("Price"),
                            title: Text(
                                completeRide.price.toStringAsFixed(0) + " ETB"),
                          ),
                        ),
                        Card(
                          child: ListTile(
                            leading: Text("Distance"),
                            title: Text(
                                completeRide.distance.toStringAsFixed(0) +
                                    " meters"),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
            Column(
              children: [
                Text("Rate your experience"),
                RatingBar.builder(
                  initialRating: 4.0,
                  direction: Axis.horizontal,
                  itemCount: 5,
                  unratedColor: Theme.of(context).backgroundColor,
                  itemBuilder: (context, _) => const Icon(
                    Icons.star,
                    color: Colors.amber,
                  ),
                  tapOnlyMode: true,
                  itemSize: 40,
                  onRatingUpdate: (rating) {},
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextFormField(
                    maxLines: 5,
                    onSaved: (value) {
                      //  = value;
                    },
                    decoration: InputDecoration(
                      hintText: "Write a review",
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: ElevatedButton(
                      onPressed: () async {
                        // if (
                        //   await bookedRideController
                        //     .confirmPayment(true)) {
                        // }
                        Navigator.of(context).pop();
                      },
                      child: const Text("Submit")),
                ),
              ],
            ),
            const SizedBox(
              height: 15.0,
            ),
          ],
        ),
      ),
    ));
  }
}
