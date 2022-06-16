import 'package:findgo_admin/core/constants.dart';
import 'package:findgo_admin/data_models/store.dart';
import 'package:findgo_admin/data_models/store_stats.dart';
import 'package:findgo_admin/main.dart';
import 'package:findgo_admin/view_models/specials_vm.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vrouter/vrouter.dart';

class StoreStatsPage extends ConsumerStatefulWidget {
  final Store store;
  const StoreStatsPage({Key? key, required this.store}) : super(key: key);

  @override
  _StoreStatsPageState createState() => _StoreStatsPageState();
}

class _StoreStatsPageState extends ConsumerState<StoreStatsPage> {
  late StoreStats _storeStats;

  @override
  void initState() {
    final _specialVM = ref.read(specialsVMProvider);
    // _specialVM.state = SpecialViewState.busy;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _storeStats =
          await _specialVM.getStoreStats(storeUuid: widget.store.uuid);
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () => context.vRouter.to("/", isReplacement: true),
            icon: const Icon(Icons.arrow_back_ios),
          ),
          title: Text(widget.store.name),
        ),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: SingleChildScrollView(
            child: Center(
              child: SizedBox(
                width: 300,
                child: _statsSection(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _statsSection() {
    return Consumer(
      builder: (context, ref, _) {
        final specialVM = ref.watch(specialsVMProvider);

        return Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  splashRadius: 24.0,
                  onPressed: () async {
                    await specialVM.getAllSpecials();
                    _storeStats = await specialVM.getStoreStats(
                      storeUuid: widget.store.uuid,
                    );
                    setState(() {});
                  },
                  icon: const Icon(
                    Icons.refresh,
                    color: Colors.white,
                  ),
                ),
                const Expanded(child: Center(child: Text("Restaurant Stats"))),
                const SizedBox(width: 40.0)
              ],
            ),
            const SizedBox(height: 8.0),
            if (specialVM.state == SpecialViewState.busy)
              const CircularProgressIndicator()
            else
              Card(
                color: kColorSelected,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          // _statCard(title: "Impressions", number: _storeStats.impressions),
                          _statCard(
                            title: "Clicks",
                            number: _storeStats.clicks,
                          ),
                          _statCard(
                            title: "Phone Clicks",
                            number: _storeStats.phoneClicks,
                          ),
                          _statCard(
                            title: "Saved Clicks",
                            number: _storeStats.savedClicks,
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 8.0,
                      ),
                      Row(
                        children: [
                          // _statCard(title: "Saved Clicks", number: _storeStats.savedClicks),
                          _statCard(
                            title: "Shared Clicks",
                            number: _storeStats.sharedClicks,
                          ),
                          _statCard(
                            title: "Website Clicks",
                            number: _storeStats.websiteClicks,
                          ),
                          const Expanded(child: SizedBox()),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  final _formHeadingTextStyle = const TextStyle(
    fontSize: 12.0,
    color: kColorSecondaryText,
  );

  Widget _statCard({required String title, required num number}) {
    return Expanded(
      child: Column(
        children: [
          Text(
            title,
            style: _formHeadingTextStyle,
          ),
          const SizedBox(height: 8.0),
          Text(
            number.toString(),
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }
}
