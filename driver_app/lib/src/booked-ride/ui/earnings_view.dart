import 'package:driver_app/src/booked-ride/booked_ride_controller.dart';
import 'package:driver_app/src/booking/bookings_list_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EarningView extends ConsumerStatefulWidget {
  const EarningView({
    Key? key,
  }) : super(key: key);
  static const routeName = "/earnings";
  @override
  ConsumerState<EarningView> createState() => _EarningViewState();
}

class _EarningViewState extends ConsumerState<EarningView> {
  @override
  Widget build(BuildContext context) {
    final bookedRideController = ref.watch(bookedRideProvider);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          foregroundColor: Colors.black,
          centerTitle: true,
          title: Text(
            "Earnings",
            style: Theme.of(context).textTheme.headline6,
          ),
          bottom: TabBar(
            tabs: [
              Tab(text: "Today"),
              Tab(
                text: "This week",
              ),
              Tab(
                text: "This month",
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          children: [
                            Text(
                              "25",
                              style: Theme.of(context).textTheme.headline5,
                            ),
                            Text("Total rides",
                                style: Theme.of(context).textTheme.headline6),
                          ],
                        ),
                        Column(
                          children: [
                            Text("3.0",
                                style: Theme.of(context).textTheme.headline5),
                            Text("Online hours",
                                style: Theme.of(context).textTheme.headline6),
                          ],
                        ),
                        Column(
                          children: [
                            Text("\$250",
                                style: Theme.of(context).textTheme.headline5),
                            Text("Total earning",
                                style: Theme.of(context).textTheme.headline6),
                          ],
                        ),
                      ],
                    ),
                  ),
                  BookingListView()
                ],
              ),
            ),
            Column(
              children: [Container()],
            ),
            Column(
              children: [Container()],
            )
          ],
        ),
      ),
    );
  }
}
