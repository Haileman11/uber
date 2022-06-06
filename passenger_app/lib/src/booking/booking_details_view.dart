import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import 'booking.dart';

/// Displays detailed information about a SampleItem.
class BookingDetailsView extends ConsumerStatefulWidget {
  final Booking booking;

  const BookingDetailsView(this.booking, {Key? key}) : super(key: key);

  static const routeName = '/booking';

  @override
  ConsumerState<BookingDetailsView> createState() => _BookingDetailsViewState();
}

class _BookingDetailsViewState extends ConsumerState<BookingDetailsView> {
  @override
  Widget build(BuildContext context) {
    Booking booking = widget.booking;
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
                            title: Text(booking.bookingRequest.price
                                    .toStringAsFixed(0) +
                                " ETB"),
                          ),
                        ),
                        Card(
                          child: ListTile(
                            leading: Text("Distance"),
                            title: Text(booking.bookingRequest.route.distance
                                    .toStringAsFixed(0) +
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
