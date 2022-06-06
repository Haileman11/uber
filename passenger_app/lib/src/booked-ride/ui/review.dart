import 'package:passenger_app/src/booking/booking.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:passenger_app/src/services/booking_data.dart';

class ReviewView extends ConsumerStatefulWidget {
  final Booking booking;

  const ReviewView(this.booking, {Key? key}) : super(key: key);

  static const routeName = '/booking';

  @override
  ConsumerState<ReviewView> createState() => _ReviewViewState();
}

class _ReviewViewState extends ConsumerState<ReviewView> {
  @override
  Widget build(BuildContext context) {
    Booking booking = widget.booking;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        const SizedBox(
          height: 10.0,
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 40.0,
              backgroundColor: Colors.transparent,
              backgroundImage: NetworkImage("https://picsum.photos/200/300"),
            ),
            Column(
              children: [
                const SizedBox(height: 8),
                Text(
                  "${booking.bookedRide!.driverInfo.firstName} ${booking.bookedRide!.driverInfo.firstName}",
                  style: Theme.of(context).textTheme.headline6,
                  maxLines: 2,
                ),
                Text(
                  "${booking.bookedRide!.driverInfo.userName}",
                ),
              ],
            ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Rate your experience",
                style: Theme.of(context).textTheme.headline6,
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Text("Behavior"),
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
                        itemSize: 25,
                        onRatingUpdate: (rating) {},
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Text("Security"),
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
                        itemSize: 25,
                        onRatingUpdate: (rating) {},
                      ),
                    ],
                  ),
                )
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Text("Hire Again "),
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
                        itemSize: 25,
                        onRatingUpdate: (rating) {},
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Text("Driving Skill"),
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
                        itemSize: 25,
                        onRatingUpdate: (rating) {},
                      ),
                    ],
                  ),
                )
              ],
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
            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: ElevatedButton(
                        onPressed: () async {
                          // if (
                          //   await bookedRideController
                          //     .confirmPayment(true)) {
                          // }
                          ref.read(bookingDataProvider).setActiveBooking(null);
                        },
                        child: const Text("Submit")),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(
          height: 15.0,
        ),
      ],
    );
  }
}
