import 'package:chat/controllers/profile_conroller.dart';
import 'package:chat/themes/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:get/get.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Profile"),
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(Icons.arrow_back),
        ),
        actions: [
          Obx(
            () => TextButton(
              onPressed:
                  controller.isediting
                      ? controller.toggleediting
                      : controller.toggleediting,
              child: Text(
                controller.isediting ? "Cancel" : "Edit",
                style: TextStyle(
                  color:
                      controller.isediting
                          ? AppTheme.errorcolor
                          : AppTheme.primecolor,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Obx(() {
        final user = controller.currentuser;
        if (user == null) {
          return Center(
            child: CircularProgressIndicator(color: AppTheme.primecolor),
          );
        }
        return SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: Column(
            children: [
              Column(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: AppTheme.primecolor,
                        child:
                            user.photourl.isNotEmpty
                                ? ClipOval(
                                  child: Image.network(
                                    user.photourl,
                                    width: 120,
                                    height: 120,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return _builddefultuseravatar(user);
                                    },
                                  ),
                                )
                                : _builddefultuseravatar(user),
                      ),
                      if (controller.isediting)
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppTheme.primecolor,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: IconButton(
                              onPressed: () {
                                Get.snackbar(
                                  "Info",
                                  "phot update coming soon!",
                                );
                              },
                              icon: Icon(
                                Icons.camera_alt,
                                size: 20,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Text(
                    user.displayname,
                    style: Theme.of(Get.context!).textTheme.headlineSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text(
                    user.email,
                    style: Theme.of(Get.context!).textTheme.bodyMedium
                        ?.copyWith(color: AppTheme.textsecondrycolor),
                  ),
                  SizedBox(height: 8),
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 4, horizontal: 12),
                    decoration: BoxDecoration(
                      color:
                          user.isonline
                              ? AppTheme.succescolor.withOpacity(.1)
                              : AppTheme.textsecondrycolor.withOpacity(.1),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          height: 8,
                          width: 8,
                          decoration: BoxDecoration(
                            color:
                                user.isonline
                                    ? AppTheme.succescolor
                                    : AppTheme.textsecondrycolor,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        SizedBox(width: 10),
                        Text(
                          user.isonline ? "online" : "offline",
                          style: Theme.of(
                            Get.context!,
                          ).textTheme.bodyLarge?.copyWith(
                            color:
                                user.isonline
                                    ? AppTheme.succescolor
                                    : AppTheme.textsecondrycolor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    controller.getjoineddata(),
                    style: Theme.of(Get.context!).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textsecondrycolor,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 32),
              Obx(
                () => Card(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Text(
                          "personal information",
                          style: Theme.of(
                            Get.context!,
                          ).textTheme.headlineSmall?.copyWith(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 20),
                        TextFormField(
                          controller: controller.displaynamecontroller,
                          enabled: controller.isediting,
                          decoration: InputDecoration(
                            labelText: "Display name",
                            prefixIcon: Icon(Icons.person_2_outlined),
                          ),
                        ),
                        SizedBox(height: 20),
                        TextFormField(
                          controller: controller.emailcontroller,
                          enabled: false,
                          decoration: InputDecoration(
                            labelText: "Email",
                            prefixIcon: Icon(Icons.email),
                            helperText: 'Email can not be change',
                          ),
                        ),
                        if (controller.isediting) ...[
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed:
                                  controller.isloading
                                      ? null
                                      : controller.updateprofile,
                              child:
                              controller.isloading?
                              SizedBox(height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),):
                               Text("Save change"),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 32,),
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: Icon(Icons.security,
                      color: AppTheme.primecolor,),
                      title: Text("change password"),
                      trailing: Icon(Icons.arrow_forward_ios),
                      onTap: () => Get.toNamed('/changepassword'),
                    ),
                    Divider(height: 1,color: Colors.grey,),
                      ListTile(
                      leading: Icon(Icons.delete_forever,
                      color: AppTheme.errorcolor,),
                      title: Text("Delet account"),
                      trailing: Icon(Icons.arrow_forward_ios),
                      onTap: controller.deletaccount,
                    ),
                    Divider(height: 1,color: Colors.grey,),
                      ListTile(
                      leading: Icon(Icons.logout,
                      color: AppTheme.errorcolor,),
                      title: Text("Sign Out"),
                      trailing: Icon(Icons.arrow_forward_ios),
                      onTap: controller.signout,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20,),
              Text("chatApp v1.0.0",style: Theme.of(Get.context!).textTheme.bodySmall?.copyWith(
                color: AppTheme.textsecondrycolor
              ),)
            ],
          ),
        );
      }),
    );
  }

  Widget _builddefultuseravatar(dynamic user) {
    return Text(
      user.displayname.isNotEmpty ? user.displayname[0].toUpperCase() : "?",
      style: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w600,
        fontSize: 32,
      ),
    );
  }
}
