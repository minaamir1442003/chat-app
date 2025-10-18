import 'package:chat/controllers/change_password.dart';
import 'package:chat/themes/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/get_core.dart';

class ChangePasswordView extends StatefulWidget {
  const ChangePasswordView({super.key});

  @override
  State<ChangePasswordView> createState() => _ChangePasswordViewState();
}

class _ChangePasswordViewState extends State<ChangePasswordView> {
  @override
  Widget build(BuildContext context) {
    final contoller = Get.put(ChangePasswordcontroller());
    return Scaffold(
      appBar: AppBar(title: Text("change password")),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Form(
            key: contoller.formkey,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: 20),
                  Center(
                    child: Container(
                      height: 100,
                      width: 100,
                      decoration: BoxDecoration(
                        color: AppTheme.primecolor.withOpacity(.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.security_rounded,
                        size: 40,
                        color: AppTheme.primecolor,
                      ),
                    ),
                  ),
                  SizedBox(height: 24),
                  Text(
                    "update your password",
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8),
                  Text(
                    "entery your current password and  choose a new secure password",
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textsecondrycolor,
                    ),
                    textAlign: TextAlign.start,
                  ),
                  SizedBox(height: 40),
                  Obx(
                    () => TextFormField(
                      controller: contoller.currentpasswordcontroller,
                      obscureText: contoller.obsscurecurrentpassword,
                      decoration: InputDecoration(
                        labelText: "Current password",
                        prefixIcon: Icon(Icons.lock_outlined),
                        suffix: IconButton(
                          onPressed: contoller.togglecurrentpasswordvisiblity,
                          icon: Icon(
                            contoller.obsscurecurrentpassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                        ),
                        hintText: "Enter your current password",
                      ),
                      validator: contoller.validatecurrentpassword,
                    ),
                  ),
                  SizedBox(height: 20),
                  Obx(
                    () => TextFormField(
                      controller: contoller.newpasswordcontroller,
                      obscureText: contoller.obsscurenewpassword,
                      decoration: InputDecoration(
                        labelText: "New password",
                        prefixIcon: Icon(Icons.lock_outlined),
                        suffix: IconButton(
                          onPressed: contoller.togglenewpasswordvisiblity,
                          icon: Icon(
                            contoller.obsscurenewpassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                        ),
                        hintText: "Enter your New password",
                      ),
                      validator: contoller.validatenewpassword,
                    ),
                  ),
                  SizedBox(height: 20),
                  Obx(
                    () => TextFormField(
                      controller: contoller.confirmpasswordcontroller,
                      obscureText: contoller.obsecureconfirmpassword,
                      decoration: InputDecoration(
                        labelText: "comfirm new password",
                        prefixIcon: Icon(Icons.lock_outlined),
                        suffix: IconButton(
                          onPressed: contoller.toggleconfirmpasswordvisiblity,
                          icon: Icon(
                            contoller.obsecureconfirmpassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                        ),
                        hintText: "comfirm new password",
                      ),
                      validator: contoller.validateconfirmpassword,
                    ),
                  ),
                  SizedBox(height: 40),
                  Obx(
                    () => SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed:
                            contoller.isloading
                                ? null
                                : contoller.changepassword,
                                icon: contoller.isloading?
                                SizedBox(height: 20,width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,

                                ),):Icon(Icons.security),
                        label: Text(contoller.isloading? "upadting....": "update pasword"),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
