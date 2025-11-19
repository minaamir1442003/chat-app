import 'package:chat/controllers/auth_controoler.dart';
import 'package:chat/controllers/home_controller.dart';
import 'package:chat/controllers/main_controller.dart';
import 'package:chat/themes/app_theme.dart';
import 'package:chat/views/widget/chat_list_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:get/get.dart';

class HomeView extends GetView<HomeController> {
  @override
  Widget build(BuildContext context) {
    final AuthController authcontroller = Get.find<AuthController>();
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildappbar(context, authcontroller),
      body: Column(
        children: [
          _buildsearchbar(),
          Obx(
            () =>
                controller.issearching && controller.searchquery.isNotEmpty
                    ? _buildsearchresults()
                    : _buildquickfilters(),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: controller.refrechchat,
              color: AppTheme.primecolor,
              child: Obx(() {
                if (controller.chats.isEmpty) {
                  if (controller.issearching &&
                      controller.searchquery.isNotEmpty) {
                    return _buildnosearchresults();
                  } else if (controller.activefilter != 'all') {
                    return _buildnofilterresults();
                  } else {
                    return _buildemptystate();
                  }
                }
                return _buildchatslist();
              }),
            ),
          ),
        ],
      ),
      floatingActionButton: _buildfloatingactionbutton(),
    );
  }

  PreferredSizeWidget _buildappbar(
    BuildContext context,
    AuthController authcontroller,
  ) {
    return AppBar(
      backgroundColor: Colors.white,
      foregroundColor: AppTheme.textprimarycolor,
      elevation: 0,
      title: Obx(
        () => Text(
          controller.issearching ? 'searching result' : 'messages',
          // style: TextStyle(fontSize: 24,fontWeight: FontWeight.w700),
        ),
      ),
      automaticallyImplyLeading: false,
      actions: [
        Obx(
          () =>
              controller.issearching
                  ? IconButton(
                    onPressed: controller.clearsearch,
                    icon: Icon(Icons.clear_rounded),
                  )
                  : _buildnotificationbutton(),
        ),
        SizedBox(width: 8),
      ],
    );
  }

  Widget _buildnotificationbutton() {
    return Obx(() {
      final unreadnotification = controller.getunreadnotificationcount();
      return Container(
        padding: EdgeInsets.only(right: 8),
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                onPressed: controller.opennotifications,
                icon: Icon(Icons.notifications_outlined),
                iconSize: 22,
                splashRadius: 20,
              ),
            ),
            if (unreadnotification > 0)
              Positioned(
                right: 6,
                top: 6,
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 2, horizontal: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.errorcolor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                  constraints: BoxConstraints(minHeight: 16, minWidth: 16),
                  child: Text(
                    unreadnotification > 99
                        ? '+99'
                        : unreadnotification.toString(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
      );
    });
  }

  Widget _buildsearchbar() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(16, 8, 15, 12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: TextField(
          onChanged: controller.onsearchchanged,
          decoration: InputDecoration(
            hintText: 'search conversations...',
            hintStyle: TextStyle(color: Colors.grey[500], fontSize: 15),
            prefixIcon: Icon(
              Icons.search_rounded,
              color: Colors.grey[500],
              size: 20,
            ),
            suffixIcon: Obx(
              () =>
                  controller.searchquery.isNotEmpty
                      ? IconButton(
                        onPressed: controller.clearsearch,
                        icon: Icon(
                          Icons.clear_rounded,
                          color: Colors.grey[500],
                          size: 18,
                        ),
                      )
                      : SizedBox.shrink(),
            ),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          ),
        ),
      ),
    );
  }

  Widget _buildquickfilters() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            Obx(
              () => _buildfilterchip(
                'all',
                () => controller.setfilter('all'),
                controller.activefilter == 'all',
              ),
            ),
            SizedBox(width: 8),
            Obx(
              () => _buildfilterchip(
                'unread {${controller.getunreadcount()}}',
                () => controller.setfilter('unread'),
                controller.activefilter == 'unread',
              ),
            ),
            SizedBox(width: 8),
            Obx(
              () => _buildfilterchip(
                'recent {${controller.getrecentcount()}}',
                () => controller.setfilter('recent'),
                controller.activefilter == 'recent',
              ),
            ),
            SizedBox(width: 8),
            Obx(
              () => _buildfilterchip(
                'active {${controller.getactivecount()}}',
                () => controller.setfilter('active'),
                controller.activefilter == 'active',
              ),
            ),
            SizedBox(width: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildfilterchip(String label, VoidCallback ontap, bool isselected) {
    return GestureDetector(
      onTap: ontap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          color: isselected ? AppTheme.primecolor : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isselected ? Colors.white : AppTheme.textsecondrycolor,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildsearchresults() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(16, 8, 18, 8),
      child: Row(
        children: [
          Obx(
            () => Text(
              'found ${controller.filteredchats.length} result${controller.filteredchats.length == 1 ? '' : 's'}',
              style: TextStyle(fontSize: 14, color: AppTheme.textsecondrycolor),
            ),
          ),
          Spacer(),
          TextButton(
            onPressed: controller.clearsearch,
            child: Text(
              'Clear',
              style: TextStyle(
                color: AppTheme.primecolor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildnosearchresults() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.search_off_rounded, size: 64, color: Colors.grey[400]),
              SizedBox(height: 16),
              Text(
                'no conversations found',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textprimarycolor,
                ),
              ),
              SizedBox(height: 8),
              Obx(
                () => Text(
                  'no result for "${controller.searchquery}"',
                  style: TextStyle(color: AppTheme.textsecondrycolor),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildnofilterresults() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _getfiltericon(controller.activefilter),
                size: 64,
                color: Colors.grey[400],
              ),
              SizedBox(height: 16),
              Text(
                "no ${controller.activefilter.toLowerCase()} conversations",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textprimarycolor,
                ),
              ),
              SizedBox(height: 8),
              Text(
                _getfilteremptymessage(controller.activefilter),
                style: TextStyle(color: AppTheme.textsecondrycolor),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => controller.setfilter('all'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primecolor,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),

                child: Text("show all conversations"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getfiltericon(String filter) {
    switch (filter) {
      case 'unread':
        return Icons.mark_email_unread_outlined;
      case 'recent':
        return Icons.schedule_outlined;
      case 'active':
        return Icons.trending_up_outlined;
      default:
        return Icons.filter_list_outlined;
    }
  }

  String _getfilteremptymessage(String filter) {
    switch (filter) {
      case 'unread':
        return "All you conversations are up to date";
      case 'recent':
        return "no conversations from the last 3 day";
      case 'active':
        return "no conversations from  the last week";
      default:
        return "no conversations found";
    }
  }

  Widget _buildchatslist() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          if (!controller.issearching || controller.searchquery.isEmpty)
            _buildchatheader(),
          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.symmetric(
                vertical: controller.issearching ? 16 : 8,
                horizontal: 16,
              ),
              itemCount: controller.chats.length,
              separatorBuilder:
                  (context, index) =>
                      Divider(height: 1, color: Colors.grey[200], indent: 72),
              itemBuilder: (context, index) {
                final chat = controller.chats[index];
                final otheruser = controller.getotheruser(chat);
                if (otheruser == null) {
                  return SizedBox.shrink();
                }
                return AnimatedContainer(
                  duration: Duration(milliseconds: 200),
                  child: ChatListItem(
                    chat: chat,
                    otheruser: otheruser,
                    lastmessagetime: controller.formatlastmessagetime(
                      chat.lastMessageTime,
                    ),
                    ontap: () => controller.openchat(chat),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildchatheader() {
    return Container(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Obx(() {
            String title = 'recent chats';
            switch (controller.activefilter) {
              case 'unread':
                title = 'unread mesaages';
                break;
              case 'recent':
                title = 'recent mesaages';
                break;
              case 'active':
                title = 'active mesaages';
                break;
            }
            return Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.textprimarycolor,
              ),
            );
          }),
          Row(
            children: [
              if (controller.activefilter != 'all')
                TextButton(
                  onPressed: controller.clearallfilters,
                  child: Text(
                    'clear filter',
                    style: TextStyle(
                      color: AppTheme.primecolor,
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildfloatingactionbutton() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primecolor,
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: FloatingActionButton.extended(
        backgroundColor: AppTheme.primecolor,
        foregroundColor: Colors.white,
        elevation: 0,
        icon: Icon(Icons.chat_rounded, size: 20),
        onPressed: () {
                        final maincontroller = Get.find<MainController>();
              maincontroller.changetabindex(1);
        },
        label: Text(
          "New Chat",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
      ),
    );
  }

  Widget _buildemptystate() {
    return SingleChildScrollView(
      physics: AlwaysScrollableScrollPhysics(),
      child: Container(
        height: MediaQuery.of(Get.context!).size.height * 0.6,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildemptystateicon(),
                SizedBox(height: 24),
                _buildemptystatetext(),
                _buildemptystateaction(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildemptystateicon() {
    return Container(
      width: 140,
      height: 140,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primecolor.withOpacity(0.1),
            AppTheme.primecolor.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(70),
      ),
      child: Icon(
        Icons.chat_bubble_outline_rounded,
        size: 64,
        color: AppTheme.primecolor,
      ),
    );
  }

  Widget _buildemptystatetext() {
    return Column(
      children: [
        Text(
          "no conversations yet",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppTheme.textprimarycolor,
          ),
        ),
        SizedBox(height: 8),
        Text(
          "connect with friends and start meaningful conversations",
          style: TextStyle(color: AppTheme.textsecondrycolor, height: 1.4),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildemptystateaction() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              final maincontroller = Get.find<MainController>();
              maincontroller.changetabindex(2);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primecolor,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),

              ),
            
            ),
            icon: Icon(Icons.person_search_rounded),
            label: Text("find people",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600
            ),
            ),
          ),
        ),
        SizedBox(height: 12,),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {
              final maincontroller = Get.find<MainController>();
              maincontroller.changetabindex(1);
            },
            style: ElevatedButton.styleFrom(
              foregroundColor: AppTheme.primecolor,
              padding: EdgeInsets.symmetric(vertical: 16),
              side: BorderSide(color: AppTheme.primecolor),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),

              ),
            
            ),
            icon: Icon(Icons.person_search_rounded),
            label: Text("view friends",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600
            ),
            ),
          ),
        ),
      ],
    );
  }
}
