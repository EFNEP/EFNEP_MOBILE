  // ignore_for_file: file_names

  class UserData {
    String? uid;
    String? email;
    String? photoUrl;
    String? displayName;
    String? authStatusMessage;
    String? phone;
    bool? isNewUser;

    UserData({
      required this.uid,
      required this.email,
      required this.displayName,
      this.photoUrl,
      this.authStatusMessage,
      this.phone,
      this.isNewUser,
    }) {
      // notifyListeners();
    }

    void updateData({
      String? uid,
      String? email,
      String? photoUrl,
      String? displayName,
      String? authStatusMessage,
      String? phone,
      bool? isNewUser,
    }) {
      if (uid != null) {
        this.uid = uid;
      }
      if (email != null) {
        this.email = email;
      }
      if (photoUrl != null) {
        this.photoUrl = photoUrl;
      }
      if (displayName != null) {
        this.displayName = displayName;
      }
      if (authStatusMessage != null) {
        this.authStatusMessage = authStatusMessage;
      }
      if (phone != null) {
        this.phone = phone;
      }
      if (isNewUser != null) {
        this.isNewUser = isNewUser;
      }
      // notifyListeners();
    }

    void updateUserUsingObject(UserData user) {
      uid = user.uid;
      email = user.email;
      photoUrl = user.photoUrl;
      displayName = user.displayName;
      authStatusMessage = user.authStatusMessage;
      phone = user.phone;
      // notifyListeners();
    }
  }
