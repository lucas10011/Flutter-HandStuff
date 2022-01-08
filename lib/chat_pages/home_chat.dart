import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hand_stuff/chat_pages/chat.dart';
import 'package:hand_stuff/chat_pages/const.dart';
import 'package:hand_stuff/models/state.dart';
import 'package:hand_stuff/services/state_widget.dart';
import 'package:hand_stuff/user_pages/user_profile.dart';
import 'package:hand_stuff/widgets/background.dart';
import 'package:intl/intl.dart';


const imageUrl = "https://images5.alphacoders.com/673/thumb-1920-673654.png";

class HomeMessages extends StatefulWidget{
  final String currentUserId;

  HomeMessages({Key key, @required this.currentUserId}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return new HomeMessagesState();
  }
}
class HomeMessagesState extends State<HomeMessages>{

  Stream<QuerySnapshot> stream;

  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

 

void initState(){
  super.initState();
  print(widget.currentUserId);
  stream = Firestore.instance.collection('users').document(widget.currentUserId).collection('messages').orderBy('timestamp', descending: true).where('notification', isEqualTo: true ).snapshots();
}
  //////////////////////Widgets


_bottomnavigationWidget(){
  return BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble,color: Colors.white),
            title: Text('Chat',style: TextStyle(color: Colors.white),),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group,color: Colors.white),
            title: Text('Elogios',style: TextStyle(color: Colors.white),),
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.white,
        onTap: _onItemTapped,
        backgroundColor: Color(0xFF1A2980),
      );
}
 
 @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    final double itemWidth = (size.width - 26);
    final double itemHeight = (size.height);

  List<Widget> _widgetOptions = <Widget>[
  
  ListMessages(currentUserId:"${widget.currentUserId}",stream: stream),
  ListUsers(currentUserId:"${widget.currentUserId}"),

  ];


    // TODO: implement build
 return new Scaffold(
      appBar: new AppBar(
        title: new Text("MyMatter"),
        backgroundColor: Color(0xFF1A2980),
      ),   
      body: Background(
        widget: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: _bottomnavigationWidget(),
    );

  }
}


class ListUsers extends StatefulWidget {
  final String currentUserId;


  ListUsers({Key key, @required this.currentUserId}) : super(key: key);

  @override
  State createState() => ListUsersState(currentUserId: currentUserId );
}

class ListUsersState extends State<ListUsers> {
  ListUsersState({Key key, @required this.currentUserId});

  final String currentUserId;
  bool isLoading = false;
  Future friendList;

  
  String peerAvatar;
  @override
  void initState() {
    super.initState();

  }


_infoFriend(id) async {


  final QuerySnapshot result = await Firestore.instance.collection('users').where('id', isEqualTo: id).getDocuments();
  final List<DocumentSnapshot> documents = result.documents;


  
  return documents[0]['user_nome'];
}

_infoImageFriend(id) async {
  
  final QuerySnapshot result = await Firestore.instance.collection('users').where('id', isEqualTo: id).getDocuments();
  final List<DocumentSnapshot> documents = result.documents;



  return documents[0]['user_foto'];
}

_imageUser(urlImg,peerId){
  return GestureDetector(
                onTap: (){ Navigator.push(
                context,
                MaterialPageRoute(
                builder: (context) => UserProfilePage(currentUserId: "${widget.currentUserId}",otherUserId:'$peerId')));},
                child: Material(
                  child: 
                  urlImg != ''
                      ? Image.network(urlImg,fit: BoxFit.cover,
                                              width: 50.0,
                                              height: 50.0,
                                              loadingBuilder:(BuildContext context, Widget child,ImageChunkEvent loadingProgress) {
                                              if (loadingProgress == null) return child;
                                                return Center(
                                                  child: CircularProgressIndicator(
                                                  value: loadingProgress.expectedTotalBytes != null ? 
                                                        loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes
                                                        : null,
                                                  ),
                                                );
                                              },
                                            )
                        : 
                        Icon(
                          Icons.account_circle,
                          size: 50.0,
                          color: greyColor,
                        ),
                  borderRadius: BorderRadius.all(Radius.circular(25.0)),
                  clipBehavior: Clip.hardEdge,
                ),
              );
}

_nomeUser(documentUserName){
    var size = MediaQuery.of(context).size;
    final double itemWidth = (size.width - 250);
  return Container(constraints: BoxConstraints(minWidth: 0, maxWidth:itemWidth),child:Text(documentUserName,overflow: TextOverflow.ellipsis),);
}


_checkImage(id) async {
  
  return _infoImageFriend('$id');                   
  
}

_checkName(id) async {
 
  return _infoFriend('$id');                   
  
}


Widget _buildImage(documentId){
  return FutureBuilder(
                future: _checkImage(documentId),
                builder: (context,snapshot){
                            if(snapshot.hasError)
                              print(snapshot.error);
                            return snapshot.hasData
                                ?_imageUser(snapshot.data,documentId)
                                :Container();
                          },
              );
}
Widget _buildName(documentId){
  
  return  Container(child: new FutureBuilder(
                          future: _checkName(documentId),
                          builder: (context,snapshot){
                            if(snapshot.hasError)
                              print(snapshot.error);
                            return snapshot.hasData
                                ?_nomeUser(snapshot.data)
                                :Container();
                          },
                        ),
                      );
}



Widget _buildDateTime(hora){
  return Text(DateFormat('dd MMM kk:mm').format(DateTime.fromMillisecondsSinceEpoch(hora.seconds * 1000)).toString(),
                     style:TextStyle(color: greyColor,fontSize: 12.0, fontStyle: FontStyle.italic,fontWeight: FontWeight.w500)

              );
}

  @override
  Widget build(BuildContext context) {
    return  Stack(
          children: <Widget>[
            // List
            Container(
              child: FutureBuilder(
                future: Firestore.instance.collection('elogios').where('user_id', isEqualTo:currentUserId).orderBy('createdAt', descending: true).limit(10).getDocuments(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(
                      child: CircularProgressIndicator(
                      ),
                    );
                  } else {
                    return Column(
                      children: <Widget>[
                        Text('Ultimos 10 elogios',style: TextStyle(color: Colors.white),),
                        Expanded(
                            child: ListView.builder(
                            padding: EdgeInsets.all(10.0),
                            itemBuilder: (context, index) => buildItem(context, snapshot.data.documents[index]),
                            itemCount: snapshot.data.documents.length,
                          ),
                        ),
                      ],
                    );
                  }
                },
              ),
            ),

            // Loading
            Positioned(
              child: isLoading
                  ? Container(
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                      color: Colors.white.withOpacity(0.8),
                    )
                  : Container(),
            )
          ],
        );
  }

  Widget buildItem(BuildContext context,document) {
      return Container(
        child: FlatButton(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Row(children: <Widget>[
              _buildImage(document['user_idfrom']),
              _buildName(document['user_idfrom']),      
              _buildDateTime(document['createdAt']),
              ],),
              
              Image.asset('assets/images/applouse.png',scale: 2.0, width: 40.0, height: 40.0),
            
            ],
          ),

          onPressed: () async {
            peerAvatar = await _checkImage('${document['user_idfrom']}');
            return Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (c, a1, a2) =>new UserProfilePage(currentUserId: "${widget.currentUserId}", otherUserId: document['user_idfrom'],),
                    transitionsBuilder: (c, anim, a2, child) => FadeTransition(opacity: anim, child: child),
                    transitionDuration: Duration(milliseconds: 400),
                  ),
                );
          },
          padding: EdgeInsets.fromLTRB(25.0, 10.0, 25.0, 10.0),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        ),
        margin: EdgeInsets.only(bottom: 10.0, left: 5.0, right: 5.0),
        decoration: BoxDecoration(
                     gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      stops: [0.3, 1],
                      colors: [
                        Color(0xFFccddff),
                        Color(0XFFe6eeff),
                        ],
                          ),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0xFF1A2980),
                          blurRadius: 10.0, // has the effect of softening the shadow
                          spreadRadius: 1.0, // has the effect of extending the shadow
                          offset: Offset(
                            2.0, // horizontal, move right 10
                            2.0, // vertical, move down 10
                          ),
                        )
                      ],
                        borderRadius: BorderRadius.all(
                      Radius.circular(16),
                    ),
                  ),
      );
    
  }
}





class ListMessages extends StatefulWidget {

final String currentUserId;
final Stream<QuerySnapshot> stream;

ListMessages({Key key, @required this.currentUserId,@required this.stream}) : super(key: key);

  @override
  
  State<StatefulWidget> createState() {
    return _ListMessagesState(currentUserId:currentUserId,stream:stream);
  }
}

class _ListMessagesState extends State<ListMessages>{
  final String currentUserId;
  final Stream<QuerySnapshot> stream;

_ListMessagesState({Key key, @required this.currentUserId,@required this.stream});

  


  @override
  Widget build(BuildContext context) {
    return _body();
      
  }

  _body() {
    return Column(
      children: <Widget>[
        MessengerAppBar(
          title: 'Chat',
        ),
        _buildRootListView(),
      ],
    );
  }

  _buildRootListView() {
    return Expanded(
      child: ListView.builder(
        itemBuilder: (context, index) {
          if (index == 0) {
            // return _buildSearchBar();
            return SizedBox(height: 50,);
          } else if (index == 1) {
            return ConversationList(currentUserId:currentUserId,stream:stream);
            //future builder
          } else {
            return _buildStoriesList();//Stream builder
          }
        },
        itemCount: 2,
      ),
    );
  }

  _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, right: 16.0),
      child: SearchBar(),
    );
  }

  _buildStoriesList() {
    return Container(
      height: 100,
      padding: EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0),
      child: StoriesList()
    );
  }
}

class MessengerAppBar extends StatefulWidget {
  
  String title;
  
  MessengerAppBar({this.title = ''});

  @override
  _MessengerAppBarState createState() => _MessengerAppBarState();
}

class _MessengerAppBarState extends State<MessengerAppBar> {

  String fotoCurrtentUser;
  StateModel appState;

_buildImageCurrentUser(userfoto){
  return Material(
        borderRadius: BorderRadius.all(Radius.circular(10.0)),
        clipBehavior: Clip.hardEdge,
    child: Image.network(userfoto,fit: BoxFit.cover,
                                              width: 35.0,
                                              height: 35.0,
                                              loadingBuilder:(BuildContext context, Widget child,ImageChunkEvent loadingProgress) {
                                              if (loadingProgress == null) return child;
                                                return Center(
                                                  child: CircularProgressIndicator(
                                                  value: loadingProgress.expectedTotalBytes != null ? 
                                                        loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes
                                                        : null,
                                                  ),
                                                );
                                              },
                                            )
  );
}
  @override
  Widget build(BuildContext context) {
    appState = StateWidget.of(context).state;

   
    final userfoto = appState?.user?.user_foto ?? '';
    return Container(
      height: 60.0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(width: 16.0,),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child:  _buildImageCurrentUser(userfoto)
                ),
              Container(width: 8.0,),
              AppBarTitle(
                text: widget.title,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class AppBarNetworkRoundedImage extends StatelessWidget {
  
  final String imageUrl;
  
  AppBarNetworkRoundedImage({@required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        height: 40,
        width: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          image: DecorationImage(
            image: NetworkImage(imageUrl)
          )
        ),
      ),
    );
  }
}

class AppBarTitle extends StatelessWidget {
  
  final String text;

  AppBarTitle({@required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: Colors.white,
        fontSize: 26,
        fontWeight: FontWeight.w700
      ),
    );
  }
}



class ConversationList extends StatefulWidget {
   final String currentUserId;
   final Stream<QuerySnapshot> stream;
  ConversationList({Key key, @required this.currentUserId,@required this.stream}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return _ConversationListState(currentUserId:currentUserId,stream:stream);
  }
}

class _ConversationListState extends State<ConversationList> {
    final String currentUserId;
    final Stream<QuerySnapshot> stream;
  _ConversationListState({Key key, @required this.currentUserId,@required this.stream});

  String imageUrl = "https://images5.alphacoders.com/673/thumb-1920-673654.png";
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        StreamBuilder(
                    stream: stream,
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return Center(
                          child: CircularProgressIndicator(
                          ),
                        );
                      } else {
                        return ListView.builder(
                          key: Key(UniqueKey().toString()),
                          physics: ScrollPhysics(),
                          shrinkWrap: true,
                          itemBuilder: (context, index) => ConversationListItem(user:snapshot.data.documents[index],currentUserId:currentUserId,index: index,),
                          itemCount: snapshot.data.documents.length,
                        );
                      }
                    },
                  ),
      ],
    );
  }
}

class ConversationListItem extends StatefulWidget {
  final int index;
  final DocumentSnapshot user;
  final String currentUserId;

  ConversationListItem({Key key, @required this.user,@required this.currentUserId,@required this.index}) : super(key: key);

  @override
  _ConversationListItemState createState() => _ConversationListItemState(key: key,index: index, userdocumentsnapshot: user, currentUserId: currentUserId );
}
  
class _ConversationListItemState extends State<ConversationListItem>  with SingleTickerProviderStateMixin{
  final int index;
  final DocumentSnapshot userdocumentsnapshot;
  final String currentUserId;
  final Key key;
_ConversationListItemState({this.key, @required this.userdocumentsnapshot,@required this.currentUserId,@required this.index});

 
  String peerAvatar;
  int secondsAnimation;
  Animation animation;
  Animation animation2;
  Animation animation3;
  Animation transformationAnim;
  AnimationController animationController;

  String groupChatId;

    @override
  void initState() {
    super.initState();
  if(widget.index <= 4){
    secondsAnimation =  widget.index + 1;
  }else{
    secondsAnimation = 5;
  }
  animationController = AnimationController(duration: Duration(seconds: secondsAnimation), vsync: this);
  
  animation2 = Tween(begin: -1.0, end:0.0).animate(CurvedAnimation(
    parent: animationController, curve: Curves.ease));

  transformationAnim = BorderRadiusTween(
    begin:BorderRadius.circular(125.0),
    end: BorderRadius.circular(0.0)).animate(CurvedAnimation(
      parent: animationController,
      curve: Curves.ease
      )
    );
  
  animationController.forward();
  }


  @override
void dispose() {
  animationController.dispose();
  super.dispose();
}

_infoImageFriend(user) async {


  final QuerySnapshot result = await Firestore.instance.collection('users').where('id', isEqualTo: user['peerId']).getDocuments();
  final List<DocumentSnapshot> documents = result.documents;

  
  return documents[0]['user_foto'];
}

_infoFriend(user) async {
 

  final QuerySnapshot result = await Firestore.instance.collection('users').where('id', isEqualTo: user['peerId']).getDocuments();
  final List<DocumentSnapshot> documents = result.documents;



  return documents[0]['user_nome'];
}
  
_checkImage(user) async {

    return _infoImageFriend(user);                   
  
}


_checkName(user) async {


  
    return _infoFriend(user);                   
  
}

         

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    return Material(
      elevation: 5,
      borderRadius: BorderRadius.all(Radius.circular(8.0)),
      child: Dismissible(  
  // Show a red background as the item is swiped away.
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        child:Icon(Icons.delete,color: Colors.white,),color: Colors.red),
      key: Key(UniqueKey().toString()), 
      onDismissed: (direction) async {
          print(currentUserId.hashCode);
          print(currentUserId.hashCode);
          if (currentUserId.hashCode <= userdocumentsnapshot['peerId'].hashCode) {
            groupChatId = '$currentUserId-${userdocumentsnapshot['peerId']}';
          } else {
            groupChatId = '${userdocumentsnapshot['peerId']}-$currentUserId';
          }
          print(groupChatId);
          try{
            await Firestore.instance.collection('users').document(currentUserId).collection('messages').document(groupChatId).updateData({'notification':false,});
          }catch(e){
            Fluttertoast.showToast(msg: "Not Found");
          }
      },
      child:InkWell(
            splashColor: Colors.blue,
            onTap: () async {
            peerAvatar = await _checkImage(userdocumentsnapshot);
            return Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (c, a1, a2) =>new Chat( peerId: '${userdocumentsnapshot['peerId']}',peerAvatar: peerAvatar,currentUserId: widget.currentUserId,),
                    transitionsBuilder: (c, anim, a2, child) => FadeTransition(opacity: anim, child: child),
                    transitionDuration: Duration(milliseconds: 400),
                  ),
                );
            },
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: <Widget>[
                FutureBuilder(
                      future: _checkImage(userdocumentsnapshot),
                      builder: (context,snapshot){
                                  if(snapshot.hasError)
                                    print(snapshot.error);
                                  return snapshot.hasData
                                      ?AnimatedBuilder(
                                        animation: animationController,
                                        builder: (BuildContext context, Widget child){
                                        return Transform(
                                          transform:Matrix4.translationValues(animation2.value * width, 0.0, 0.0),
                                          child:_buildConversationImage(snapshot.data,userdocumentsnapshot));
                                          }) 
                                      :SizedBox(width: 70.0,height: 70.0,);
                                },
                    ),
                _buildTitleAndLatestMessage(userdocumentsnapshot,width),      
              ],
            ),
          ),
      ),
     )
    );
  }

  _buildTitleAndLatestMessage(user,width) {
    return Padding(
      padding: const EdgeInsets.only(left: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          FutureBuilder(
                future: _checkName(user),
                builder: (context,snapshot){
                            if(snapshot.hasError)
                              print(snapshot.error);
                            return snapshot.hasData
                                ?AnimatedBuilder(
                                    animation: animationController,
                                    builder: (BuildContext context, Widget child){
                                    return Transform(
                                      transform:Matrix4.translationValues(animation2.value  * width, 0.0, 0.0),
                                      child:_buildConverastionTitle(snapshot.data));
                                      })
                                :Container();
                          },
              ),
          Container(height: 2,),
          Row(
            children: <Widget>[
              _buildLatestMessage(user),
              Container(width: 4,),
              Center(
                child: Text(' ')),
              Container(width: 4,),
              _buildTimeOfLatestMessage(user)
            ],
          )
        ],
      ),
    );
  }

  _buildConverastionTitle(nome) {
    var size = MediaQuery.of(context).size;
    final double itemWidth = (size.width - 130);
    return Container(
      constraints: BoxConstraints(minWidth: 0, maxWidth:itemWidth),
      child: Text(
        '$nome',
        style: TextStyle(
          fontSize: 18,
          color: Colors.black,
          fontWeight: FontWeight.bold
        ),overflow: TextOverflow.ellipsis
      ),
    );
  }
  
  _buildLatestMessage(user) {
    var size = MediaQuery.of(context).size;
    final double itemWidth = (size.width - 230);

    return Container(
      constraints: BoxConstraints(minWidth: 0, maxWidth:itemWidth),
      child: Text(
        '${user['lastmessage']}',
        style: user['read'] 
        ?TextStyle(
          color: Colors.grey.shade700
        )
        :TextStyle(
          color: Colors.grey.shade700,
          fontWeight: FontWeight.bold
        )
      ,overflow: TextOverflow.ellipsis),
    );
  }

  _buildTimeOfLatestMessage(user) {
    return Text(
      DateFormat('dd MMM kk:mm').format(DateTime.fromMillisecondsSinceEpoch(user['timestamp'].seconds * 1000)).toString(),
      style: user['read']
      ?TextStyle(
        color: Colors.grey.shade700)
      : TextStyle(color: Colors.green,fontWeight: FontWeight.w700,shadows: [
                      Shadow(blurRadius: 10.0,color: Colors.green,offset: Offset(2.0, 2.0),),],),
      
    );
  }

  _buildConversationImage(foto,user) {
    return GestureDetector(
      onTap: (){ Navigator.push(
                context,
                MaterialPageRoute(
                builder: (context) => UserProfilePage(currentUserId: "${widget.currentUserId}",otherUserId:'${widget.user['peerId']}')));},
      child: Material(
        borderRadius: BorderRadius.all(Radius.circular(25.0)),
        clipBehavior: Clip.hardEdge,
        child: foto != '' 
              ? Image.network(foto,fit: BoxFit.cover,
                                              width: 70.0,
                                              height: 70.0,
                                              loadingBuilder:(BuildContext context, Widget child,ImageChunkEvent loadingProgress) {
                                              if (loadingProgress == null) return child;
                                                return Center(
                                                  child: CircularProgressIndicator(
                                                  value: loadingProgress.expectedTotalBytes != null ? 
                                                        loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes
                                                        : null,
                                                  ),
                                                );
                                              },
                                            )
              : Icon(
                  Icons.account_circle,
                  size: 70.0,
                  color: greyColor,
                    )
      ),
    );
  }
}

class SearchBar extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _SearchBarState();
  }
}

class _SearchBarState extends State<SearchBar> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 45.0,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.grey.shade200
      ),
      child: Row(
        children: <Widget>[
          Container(width: 10.0,),
          Icon(Icons.search),
          Container(width: 8.0,),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Search'
              ),
            ),
          )
        ],
      ),
    );
  }
}



class StoriesList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _StoriesListState();
  }
}

class _StoriesListState extends State<StoriesList> {
  String imageUrl = "https://images5.alphacoders.com/673/thumb-1920-673654.png";
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemBuilder: (context, index) {
        if (index == 0) {
          return AddToYourStoryButton();
        }
        if (index <= 10) {
          return StoryListItem(
            viewed: false,
          );
        } else {
          return StoryListItem(
            viewed: true,
          );
        }
      },
      itemCount: 21,
    );
  }
}

class StoryListItem extends StatefulWidget {
  
  bool viewed;

  StoryListItem({@required this.viewed});

  @override
  State<StatefulWidget> createState() {
    return _StoryListItemState();
  }
}

class _StoryListItemState extends State<StoryListItem> {

  _buildBorder() {
    if (widget.viewed) {
      return null;
    } else {
      return Border.all(
        color: Colors.blue,
        width: 3
      );
    }
  }

  _getTextStyle() {
    if (widget.viewed) {
      return _viewedStoryListItemTextStyle();
    } else {
      return _notViewedStoryListItemTextStyle();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Column(
          children: <Widget>[
            Container(
              height: 60,
              width: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: _buildBorder(),
                image: DecorationImage(
                  image: NetworkImage(imageUrl)
                )
              ),
            ),
            Container(height: 8.0,),
            Text(
              'Abc',
              softWrap: true,
              style: _getTextStyle(),
            ),
          ],
        ),
        Container(width: 12.0,)
      ],
    );
  }
}

class AddToYourStoryButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Column(
          children: [
            Container(
              height: 60,
              width: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey.shade200,
                // borderRadius: BorderRadius.circular(5.0)
              ),
              child: Icon(
                Icons.add,
                size: 35.0,
              )
            ),
            Container(height: 8.0,),
            Text(
              'Your story',
              style: _viewedStoryListItemTextStyle()
            ),
          ],
        ),
        Container(width: 12.0,)
      ],
    );
  }
}

_notViewedStoryListItemTextStyle() {
  return TextStyle(
    fontSize: 12,
    color: Colors.black,
    fontWeight: FontWeight.bold
  );  
}

_viewedStoryListItemTextStyle() {
  return TextStyle(
    fontSize: 12,
    color: Colors.grey
  );  
}


