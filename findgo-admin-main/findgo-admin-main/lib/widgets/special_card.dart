import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/constants.dart';
import '../data_models/special.dart';

class SpecialCard extends StatelessWidget {
  final Special special;

  const SpecialCard({Key? key, required this.special}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: kColorSelected,
      elevation: 4,
      // margin: const EdgeInsets.symmetric(vertical: 12.0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            child: Column(
              children: [
                Row(
                  children: [
                    const SizedBox(width: 16.0,),
                    CircleAvatar(
                      backgroundColor: Colors.transparent,
                      // backgroundImage: NetworkImage(special.storeImageUrl)),
                      backgroundImage: NetworkImage(special.storeImageUrl),
                    ),

                    const SizedBox(width: 16.0,),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(special.storeName, style: const TextStyle(fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis,),
                          if (special.storeCategory != "") Text(special.storeCategory, style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic), overflow: TextOverflow.ellipsis,),
                        ],
                      ),
                    ),
                    // if (special.type == SpecialType.discount) InkWell(
                    //     hoverColor: Colors.transparent,
                    //     splashColor: Colors.transparent,
                    //     onTap: () async => Routes.push(context, SpecialPage(special: special)),
                    //     child: const Icon(Icons.qr_code)
                    // ),
                    if (special.typeSet.contains(SpecialType.featured)) Container(
                      color: kColorAccent,
                      // decoration: BoxDecoration(
                      //   border: Border.all(color: kColorAccent),
                      //   borderRadius: BorderRadius.circular(10.0),
                      // ),
                      padding: const EdgeInsets.all(6.0),
                      child: Row(
                        children: [
                          const Icon(Icons.star, size: 16,color: Colors.white),
                          const SizedBox(width: 4.0,),
                          const Text("Featured", style: TextStyle(color: Colors.white)),
                        ],
                      ),
                    ) else if (special.validFrom.isAfter(DateTime.now())) Container(
                      color: kColorError,
                      // decoration: BoxDecoration(
                      //   border: Border.all(color: kColorAccent),
                      //   borderRadius: BorderRadius.circular(10.0),
                      // ),
                      padding: const EdgeInsets.all(6.0),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline, size: 16,color: Colors.white),
                          const SizedBox(width: 4.0,),
                          const Text("Coming Soon", style: TextStyle(color: Colors.white)),
                        ],
                      ),
                    ),
                  ],
                ),
                if (special.imageUrl != "" || special.image != null) const SizedBox(height: 16.0),
                if (special.image != null) SizedBox(
                  // height: constraints.maxWidth * 0.8,
                  width: constraints.maxWidth,
                  child: Image.memory(
                    special.image!,
                    fit: BoxFit.fitWidth,
                  ),
                ) else if (special.imageUrl != "") SizedBox(
                  // height: constraints.maxWidth * 0.8,
                  width: constraints.maxWidth,
                  child: Image.network(
                    special.imageUrl,
                    fit: BoxFit.fitWidth,
                    alignment: Alignment.topCenter,
                  ),
                ),
                const SizedBox(height: 16.0,),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _actionRow(),
                      const SizedBox(height: 8.0),
                      SizedBox(
                        child: Text(special.name.toUpperCase(),
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)
                        ),
                      ),
                      const SizedBox(height: 16.0,),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (special.price > 0) Text("R ${(special.price / 100).toStringAsFixed(2)}", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          if (special.price > 0) const SizedBox(height: 16.0,),
                          Text(
                              DateFormat.E().add_yMMMd().add_jm().format(special.validFrom),
                              style: const TextStyle(fontSize: 10)
                          ),
                          if (special.validUntil.year > 2020) Text(
                              "Until  ${DateFormat.E().add_yMMMd().add_jm().format(special.validUntil)}",
                              style: const TextStyle(fontSize: 10)
                          ),
                        ],
                      ),
                      const SizedBox(height: 16.0,),
                      Align(
                          alignment: Alignment.topLeft,
                          child: Text(special.description, style: const TextStyle(fontSize: 12),)
                      ),
                      // const SizedBox(height: 32.0,),
                    ],
                  ),
                )
                // const Divider(
                //   indent: 50.0,
                //   endIndent: 50.0,
                //   color: kColorCard,
                //   thickness: 2.0,
                // ),
              ],
            ),
          );
        }
      ),
    );
  }

  Widget _actionRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          splashRadius: 20,
          onPressed: () async {},
          // onTap: () => context.vRouter.pushExternal("tel:${_special!.storePhoneNumber}"),
          icon: const Icon(Icons.info_outline_rounded),
        ),
        IconButton(
          splashRadius: 20,
          onPressed: () async {},
          // onTap: () => context.vRouter.pushExternal("tel:${_special!.storePhoneNumber}"),
          icon: const Icon(Icons.phone),
        ),
        IconButton(
          splashRadius: 20,
          onPressed: () async {},
          icon: const Icon(Icons.share),
        ),
        IconButton(
          splashRadius: 20,
          onPressed: () async {},
          //onTap: () => context.vRouter.pushExternal(_special!.storeWebsite),
          icon: const Icon(Icons.web),
        ),
        IconButton(
          splashRadius: 20,
          onPressed: () async {},
          //onTap: () => context.vRouter.pushExternal(_special!.storeWebsite),
          icon: const Icon(Icons.bookmark_border),
        ),
      ],
    );
  }
}
