class AppUser{

  final String uid;
  final String name;

  AppUser({required this.uid, required this.name});

  factory AppUser.fromMap(Map<String, dynamic> data){
    return AppUser(
        uid: data['uid'],
        name: data['name'],
    );
  }

  Map<String, dynamic> toMap(){
    return{
      'uid': uid,
      'name': name,
    };
  }

}