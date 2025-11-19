import 'package:chat/controllers/users_list_controller.dart';
import 'package:chat/themes/app_theme.dart';
import 'package:chat/views/widget/user_list_item.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FindPeopleView extends GetView<UsersListController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("find people"), leading: SizedBox()),
      body: Column(
        children: [
          _buildsearchbar(),
          Expanded(
            child: Obx(() {
              if (controller.filteredusers.isEmpty) {
                return _buildemptystate();
              }
              return ListView.separated(
                padding: EdgeInsets.all(16),
                itemBuilder: (context, index) {
                  final user = controller.filteredusers[index];
                  return UserListItem(
                    key: ValueKey(user.id),
                    users: user,
                    ontap: () => controller.handelrelationshipaction(user),
                    controller: controller,
                  );
                },
                separatorBuilder: (context, index) => SizedBox(height: 8),
                itemCount: controller.filteredusers.length,
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildsearchbar() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(Get.context!).scaffoldBackgroundColor,
        border: Border(
          bottom: BorderSide(
            color: AppTheme.bordercolor.withOpacity(.5),
            width: 1,
          ),
        ),
      ),
      child: TextField(
        onChanged: controller.updatesearchquery,
        decoration: InputDecoration(
          hintText: 'search people',
          prefixIcon: Icon(Icons.search),
          suffixIcon: Obx(() {
            return controller.searchquery.isNotEmpty
                ? IconButton(
                  onPressed: () {
                    controller.clearsearch();
                  },
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
          contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
        ),
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
                  ? 'no result found'
                  : 'no people found',
              style: Theme.of(Get.context!).textTheme.headlineMedium?.copyWith(
                color: AppTheme.textprimarycolor,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              controller.searchquery.isNotEmpty
                  ? 'try a different search term'
                  : 'all users will show here',
              style: Theme.of(Get.context!).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textprimarycolor,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
