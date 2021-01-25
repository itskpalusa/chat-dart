import 'package:cloud_firestore/cloud_firestore.dart';

class DBService {
  final String uid;

  DBService({this.uid});

  // Collection References
  final CollectionReference userCollection =
      FirebaseFirestore.instance.collection('users');
  final CollectionReference groupCollection =
      FirebaseFirestore.instance.collection('groups');

  // Update UserData
  Future updateUserData(String fullName, String email) async {
    return await userCollection.doc(uid).set({
      'fullName': fullName,
      'email': email,
      'groups': [],
      'profilePic': '',
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  // Get Group Name
  Future<String> getGroupName(String groupKey) async {
    DocumentReference groupDocRef = groupCollection.doc(groupKey);
    String groupName;
    await groupDocRef.get().then((snapshot) {
      groupName = snapshot.data()['groupName'];
    });
    return groupName;
  }

  // Add User To Group || Add Group to User's Document
  Future addToGroup(String groupKey, String userName, String userID) async {
    DocumentReference groupDocRef = groupCollection.doc(groupKey);
    DocumentReference userDocRef = userCollection.doc(userID);

    var groupName = await getGroupName(groupKey);
    var space = "_";

    await userDocRef.update({
      'groups': FieldValue.arrayUnion(['$groupKey$space$groupName'])
    });
    await groupDocRef.update({
      'members': FieldValue.arrayUnion(['$userID$space$userName']),
    });
  }

  // Create Group
  Future createGroup(String userName, String groupName) async {
    DocumentReference groupDocRef = await groupCollection.add({
      'groupName': groupName,
      'groupIcon': '',
      'admin': userName,
      'members': [],
      'private': false,
      'groupId': '',
      'recentMessage': '',
      'recentMessageSender': ''
    });

    await groupDocRef.update({
      'members': FieldValue.arrayUnion([uid + '_' + userName]),
      'groupId': groupDocRef.id
    });

    DocumentReference userDocRef = userCollection.doc(uid);
    return await userDocRef.update({
      'groups': FieldValue.arrayUnion([groupDocRef.id + '_' + groupName])
    });
  }

  // Toggle Group Join
  Future togglingGroupJoin(
      String groupId, String groupName, String userName) async {
    DocumentReference userDocRef = userCollection.doc(uid);
    DocumentSnapshot userDocSnapshot = await userDocRef.get();

    DocumentReference groupDocRef = groupCollection.doc(groupId);

    List<dynamic> groups = await userDocSnapshot.data()['groups'];

    if (groups.contains(groupId + '_' + groupName)) {
      print('hey');
      await userDocRef.update({
        'groups': FieldValue.arrayRemove([groupId + '_' + groupName])
      });

      await groupDocRef.update({
        'members': FieldValue.arrayRemove([uid + '_' + userName])
      });
    } else {
      print('nay');
      await userDocRef.update({
        'groups': FieldValue.arrayUnion([groupId + '_' + groupName])
      });

      await groupDocRef.update({
        'members': FieldValue.arrayUnion([uid + '_' + userName])
      });
    }
  }

  // Check if User has Joined Group
  Future<bool> isUserJoined(
      String groupId, String groupName, String userName) async {
    DocumentReference userDocRef = userCollection.doc(uid);
    DocumentSnapshot userDocSnapshot = await userDocRef.get();

    List<dynamic> groups = await userDocSnapshot.data()['groups'];

    if (groups.contains(groupId + '_' + groupName)) {
      //print('he');
      return true;
    } else {
      //print('ne');
      return false;
    }
  }

  // Get User Data
  Future getUserData(String email) async {
    QuerySnapshot snapshot =
        await userCollection.where('email', isEqualTo: email).get();
    print(snapshot.docs[0].data);
    return snapshot;
  }

  // Get User Groups
  getUserGroups() async {
    return FirebaseFirestore.instance.collection("users").doc(uid).snapshots();
  }

  // Send a Message
  sendMessage(String groupId, chatMessageData) {
    FirebaseFirestore.instance
        .collection('groups')
        .doc(groupId)
        .collection('messages')
        .add(chatMessageData);
    FirebaseFirestore.instance.collection('groups').doc(groupId).update({
      'recentMessage': chatMessageData['message'],
      'recentMessageSender': chatMessageData['sender'],
      'recentMessageTime': chatMessageData['time'].toString(),
    });
  }

  // Send a Message
  sendAttachment(String groupId, chatAttachmentData) {
    FirebaseFirestore.instance
        .collection('groups')
        .doc(groupId)
        .collection('messages')
        .add(chatAttachmentData);
    FirebaseFirestore.instance.collection('groups').doc(groupId).update({
      'recentMessage': chatAttachmentData['message'],
      'recentMessageSender': chatAttachmentData['sender'],
      'recentMessageTime': chatAttachmentData['time'].toString(),
    });
  }


  // get Group Conversation
  getChats(String groupId) async {
    return FirebaseFirestore.instance
        .collection('groups')
        .doc(groupId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  // Search Groups by Name (GLOBAL)
  searchByName(String groupName) {
    return FirebaseFirestore.instance
        .collection("groups")
        .where('groupName', isEqualTo: groupName)
        .where('private', isEqualTo: false)
        .get();
  }

  // Search User's Groups by Name
  searchByNamePrivate(String groupName) {
    return FirebaseFirestore.instance
        .collection("groups")
        .where('groupName', isEqualTo: groupName)
        .where('users', arrayContains: uid)
        .get();
  }

  // Search Groups by Token/Key if Private & Add w/ Token
  searchForPrivateGroup(String groupId) async {
    return FirebaseFirestore.instance
        .collection("groups")
        .where('groupId', isEqualTo: groupId)
        .where('private', isEqualTo: true)
        .get();
  }

// Toggle Group Privacy
  Future toggleGroupPrivacy(String groupId, bool privateStatus) async {
    DocumentReference groupDocRef = groupCollection.doc(groupId);

    await groupDocRef.update({'private': privateStatus});
  }
}
