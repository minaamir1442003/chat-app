// ignore_for_file: sort_child_properties_last

import 'package:chat/controllers/friend_controller.dart';
import 'package:chat/themes/app_theme.dart';
import 'package:chat/views/widget/friend_list_stream.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:get/get.dart';

class FriendView extends GetView<FriendController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("friends"),
        leading: SizedBox(),
        actions: [
          IconButton(
            onPressed: controller.openfriendrequests,
            icon: Icon(Icons.person_add_alt_1),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              border: Border(
                bottom: BorderSide(
                  color: AppTheme.bordercolor.withOpacity(0.5),
                  width: 1,
                ),
              ),
            ),
            child: TextField(
              onChanged: controller.updatesearchquery,
              decoration: InputDecoration(
                hintText: "search friends",
                prefixIcon: Icon(Icons.search),
                suffixIcon: Obx(() {
                  return controller.searchquery.isEmpty
                      ? IconButton(
                        onPressed: controller.cleansearch,
                        icon: Icon(Icons.clear),
                      )
                      : SizedBox.shrink();
                }),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppTheme.bordercolor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppTheme.bordercolor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppTheme.primecolor, width: 2),
                ),
                filled: true,
                fillColor: AppTheme.cardcolor,
              ),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              child: Obx(() {
                if (controller.isloading && controller.friend.isNotEmpty) {
                  return Center(child: CircularProgressIndicator());
                }
                if (controller.filteredfriends.isEmpty) {
                  return _buildemptystate();
                }
                return ListView.separated(
                  padding: EdgeInsets.all(16),
                  itemCount: controller.filteredfriends.length,
                  separatorBuilder: (context, index) {
                    return SizedBox(height: 8);
                  },
                  itemBuilder: (context, index) {
                    final friend = controller.filteredfriends[index];
                    return FriendListStream(
                      friend: friend,
                      lastseentext: controller.getlastseentext(friend),
                      ontap: ()=> controller.startchat(friend),
                      onremove: ()=> controller.removefriend(friend),
                      onblock: ()=>controller.blockfriend(friend)
                    );
                  },
                );
              }),
              onRefresh: controller.refreshfriends,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildemptystate() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppTheme.primecolor.withOpacity(.1),
                borderRadius: BorderRadius.circular(50),
              ),
              child: Icon(
                Icons.people_outlined,
                size: 50,
                color: AppTheme.primecolor,
              ),
            ),
            SizedBox(height: 24),
            Text(
              controller.searchquery.isNotEmpty
                  ? 'no friend found'
                  : 'no friends yet',
              style: Theme.of(Get.context!).textTheme.headlineMedium?.copyWith(
                color: AppTheme.textprimarycolor,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              controller.searchquery.isNotEmpty
                  ? 'try a different search term'
                  : 'add friends to start chating with them',
              style: Theme.of(Get.context!).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textsecondrycolor,
              ),
              textAlign: TextAlign.center,
            ),
            if (controller.searchquery.isEmpty) ...[
              SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: controller.openfriendrequests,
                label: Text("view friend requests"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primecolor,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
