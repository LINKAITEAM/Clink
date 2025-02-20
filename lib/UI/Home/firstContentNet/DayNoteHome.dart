// ignore_for_file: non_constant_identifier_names
import 'package:clickbyme/Tool/BGColor.dart';
import 'package:clickbyme/Tool/ContainerDesign.dart';
import 'package:clickbyme/Tool/IconBtn.dart';
import 'package:clickbyme/Tool/TextSize.dart';
import 'package:clickbyme/UI/Events/ADEvents.dart';
import 'package:clickbyme/UI/Home/firstContentNet/DayScript.dart';
import 'package:clickbyme/sheets/pushalarmsettingmemo.dart';
import 'package:clickbyme/sheets/settingsecurityform.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fab_circular_menu/fab_circular_menu.dart';
import 'package:flutter/services.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:focused_menu/focused_menu.dart';
import 'package:focused_menu/modals.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:local_auth/local_auth.dart';
import '../../../Sub/SecureAuth.dart';
import '../../../Tool/Getx/memosetting.dart';
import '../../../Tool/Getx/selectcollection.dart';
import '../../../Tool/NoBehavior.dart';
import '../../../sheets/calendarinfo.dart';
import '../../Sign/UserCheck.dart';
import '../Widgets/SortMenuHolder.dart';
import '../secondContentNet/ClickShowEachNote.dart';

class DayNoteHome extends StatefulWidget {
  const DayNoteHome({Key? key, required this.title, required this.isfromwhere})
      : super(key: key);
  final String title;
  final String isfromwhere;
  @override
  State<StatefulWidget> createState() => _DayNoteHomeState();
}

class _DayNoteHomeState extends State<DayNoteHome> with WidgetsBindingObserver {
  double translateX = 0.0;
  double translateY = 0.0;
  double myWidth = 0.0;
  int searchmemo_fromsheet = 0;
  final controll_memo = Get.put(memosetting());
  final scollection = Get.put(selectcollection());
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  final searchNode = FocusNode();
  final setalarmhourNode = FocusNode();
  final setalarmminuteNode = FocusNode();
  String username = Hive.box('user_info').get(
    'id',
  );
  String usercode = Hive.box('user_setting').get('usercode');
  List<String> textsummary = [];
  String tmpsummary = '';
  DateTime Date = DateTime.now();
  TextEditingController controller = TextEditingController();
  ScrollController _scrollController = ScrollController();
  bool _showBackToTopButton = false;
  bool isresponsive = false;
  bool canAuthenticate = false;
  LocalAuthentication auth = LocalAuthentication();
  bool can_auth = false;
  String hour = '';
  String minute = '';
  late FToast fToast;
  ValueNotifier<bool> isDialOpen = ValueNotifier(false);

  Future<void> _checkBiometrics() async {
    bool check = false;

    try {
      check = await auth.canCheckBiometrics;
      canAuthenticate = check && await auth.isDeviceSupported();
    } on PlatformException catch (e) {}
    if (!mounted) return;
    setState(() {
      can_auth = canAuthenticate;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    initializeDateFormatting(Localizations.localeOf(context).languageCode);
  }

  @override
  void initState() {
    super.initState();
    _checkBiometrics();
    fToast = FToast();
    fToast.init(context);
    WidgetsBinding.instance.addObserver(this);
    Hive.box('user_setting').put('sort_memo_card', 0);
    controll_memo.sort = Hive.box('user_setting').get('sort_memo_card');
    controller = TextEditingController();
    _scrollController = ScrollController()
      ..addListener(() {
        setState(() {
          if (_scrollController.offset >= 150) {
            _showBackToTopButton = true; // show the back-to-top button
          } else {
            _showBackToTopButton = false; // hide the back-to-top button
          }
        });
      });
    firestore.collection('MemoAllAlarm').doc(usercode).get().then((value) {
      if (value.exists) {
        value.data()!.forEach((key, value) {
          if (key == 'alarmtime') {
            Hive.box('user_setting').put(
                'alarm_memo_hour', int.parse(value.toString().split(':')[0]));
            Hive.box('user_setting').put(
                'alarm_memo_minute', int.parse(value.toString().split(':')[1]));
            firestore.collection('MemoAllAlarm').doc(usercode).update({
              'alarmtime': value.toString().split(':')[0] +
                  ':' +
                  value.toString().split(':')[1]
            });
            /*controll_memo.settimeminute(
                int.parse(value.toString().split(':')[0]),
                int.parse(value.toString().split(':')[1]),
                '',
                '');*/
          } else if (key == 'ok') {
            Hive.box('user_setting').put('alarm_memo', value);
            controll_memo.ischeckedpushmemoalarm = value;
          } else {}
        });
      } else {
        firestore
            .collection('MemoAllAlarm')
            .doc(usercode)
            .set({'ok': false, 'alarmtime': '99:99'});
        Hive.box('user_setting').put('alarm_memo', false);
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
    _scrollController.dispose();
    controller.dispose();
  }

  void _scrollToTop() {
    _scrollController.animateTo(0,
        duration: const Duration(seconds: 1), curve: Curves.easeIn);
    if (_scrollController.offset == 300) {
      _showBackToTopButton = false; // show the back-to-top button
    }
  }

  Speeddialmemo(
      BuildContext context,
      bool showBackToTopButton,
      String username,
      TextEditingController controller,
      FocusNode searchNode,
      selectcollection scollection,
      bool isresponsive,
      ScrollController scrollController) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        showBackToTopButton == false
            ? const SizedBox()
            : FloatingActionButton(
                onPressed: () {
                  scrollController.animateTo(0,
                      duration: const Duration(seconds: 1),
                      curve: Curves.easeIn);
                  if (scrollController.offset == 300) {
                    showBackToTopButton = false; // show the back-to-top button
                  }
                },
                backgroundColor: BGColor(),
                child: Icon(
                  Icons.arrow_upward,
                  color: TextColor(),
                ),
              ),
        const SizedBox(width: 10),
        SpeedDial(
            openCloseDial: isDialOpen,
            activeIcon: Icons.close,
            icon: Icons.add,
            backgroundColor: Colors.blue,
            overlayColor: BGColor(),
            overlayOpacity: 0.4,
            spacing: 10,
            spaceBetweenChildren: 10,
            children: [
              SpeedDialChild(
                child: NeumorphicIcon(
                  Icons.local_offer,
                  size: 30,
                  style: NeumorphicStyle(
                      shape: NeumorphicShape.convex,
                      depth: 2,
                      surfaceIntensity: 0.5,
                      color: TextColor(),
                      lightSource: LightSource.topLeft),
                ),
                backgroundColor: Colors.blue.shade200,
                onTap: () {
                  addmemocollector(context, username, controller, searchNode,
                      'outside', scollection, isresponsive);
                },
                label: '메모태그 추가',
                labelStyle: TextStyle(
                    color: Colors.black45,
                    fontWeight: FontWeight.bold,
                    fontSize: contentTextsize()),
              ),
              SpeedDialChild(
                child: NeumorphicIcon(
                  Icons.add,
                  size: 30,
                  style: NeumorphicStyle(
                      shape: NeumorphicShape.convex,
                      depth: 2,
                      surfaceIntensity: 0.5,
                      color: TextColor(),
                      lightSource: LightSource.topLeft),
                ),
                backgroundColor: Colors.orange.shade200,
                onTap: () {
                  Get.to(
                      () => DayScript(
                            firstdate: DateTime.now(),
                            lastdate: DateTime.now(),
                            position: 'note',
                            id: '',
                            share: const [],
                            orig: '',
                            calname: '',
                            isfromwhere: 'memohome',
                          ),
                      transition: Transition.downToUp);
                },
                label: '메모 추가',
                labelStyle: TextStyle(
                    color: Colors.black45,
                    fontWeight: FontWeight.bold,
                    fontSize: contentTextsize()),
              ),
            ]),
      ],
    );
  }

  Future<bool> _onWillPop() async {
    Future.delayed(const Duration(seconds: 0), () {
      if (isDialOpen.value == true) {
        isDialOpen.value = false;
      } else {
        if (widget.isfromwhere == 'home') {
          GoToMain(context);
        } else {
          Get.back();
        }
      }
    });
    return false;
  }

  @override
  Widget build(BuildContext context) {
    MediaQuery.of(context).size.height > 900
        ? isresponsive = true
        : isresponsive = false;
    return SafeArea(
        child: Scaffold(
            backgroundColor: BGColor(),
            body: WillPopScope(
              onWillPop: _onWillPop,
              child: UI(),
            ),
            floatingActionButton: Speeddialmemo(
                context,
                _showBackToTopButton,
                username,
                controller,
                searchNode,
                scollection,
                isresponsive,
                _scrollController)));
  }

  UI() {
    double height = MediaQuery.of(context).size.height;
    return SizedBox(
      height: height,
      child: Container(
          decoration: BoxDecoration(color: BGColor()),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                  height: 80,
                  child: Padding(
                    padding: const EdgeInsets.only(
                        left: 10, right: 10, top: 20, bottom: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Flexible(
                            fit: FlexFit.tight,
                            child: Row(
                              children: [
                                IconBtn(
                                    child: IconButton(
                                        onPressed: () {
                                          Future.delayed(
                                              const Duration(seconds: 0), () {
                                            if (widget.isfromwhere == 'home') {
                                              GoToMain(context);
                                            } else {
                                              Get.back();
                                            }
                                          });
                                        },
                                        icon: Container(
                                          alignment: Alignment.center,
                                          width: 30,
                                          height: 30,
                                          child: NeumorphicIcon(
                                            Icons.keyboard_arrow_left,
                                            size: 30,
                                            style: NeumorphicStyle(
                                                shape: NeumorphicShape.convex,
                                                depth: 2,
                                                surfaceIntensity: 0.5,
                                                color: TextColor(),
                                                lightSource:
                                                    LightSource.topLeft),
                                          ),
                                        )),
                                    color: TextColor()),
                                SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width - 70,
                                    child: Padding(
                                        padding: const EdgeInsets.only(
                                            left: 10, right: 10),
                                        child: Row(
                                          children: [
                                            Flexible(
                                              fit: FlexFit.tight,
                                              child: Text('Memo',
                                                  style: GoogleFonts.lobster(
                                                    fontSize: 25,
                                                    color: TextColor(),
                                                    fontWeight: FontWeight.bold,
                                                  )),
                                            ),
                                            SortMenuHolder(
                                                controll_memo.sort, '메모'),
                                            const SizedBox(
                                              width: 10,
                                            ),
                                            IconBtn(
                                                child: IconButton(
                                                    onPressed: () async {
                                                      await firestore
                                                          .collection(
                                                              'MemoAllAlarm')
                                                          .doc(usercode)
                                                          .get()
                                                          .then(
                                                        (value) {
                                                          if (value.exists) {
                                                            hour = value
                                                                        .data()![
                                                                            'alarmtime']
                                                                        .toString()
                                                                        .split(':')[
                                                                            0]
                                                                        .length ==
                                                                    1
                                                                ? '0' +
                                                                    value
                                                                        .data()![
                                                                            'alarmtime']
                                                                        .toString()
                                                                        .split(':')[
                                                                            0]
                                                                        .toString()
                                                                : value
                                                                    .data()![
                                                                        'alarmtime']
                                                                    .toString()
                                                                    .split(
                                                                        ':')[0]
                                                                    .toString();
                                                            minute = value
                                                                        .data()![
                                                                            'alarmtime']
                                                                        .toString()
                                                                        .split(':')[
                                                                            1]
                                                                        .length ==
                                                                    1
                                                                ? '0' +
                                                                    value
                                                                        .data()![
                                                                            'alarmtime']
                                                                        .toString()
                                                                        .split(':')[
                                                                            1]
                                                                        .toString()
                                                                : value
                                                                    .data()![
                                                                        'alarmtime']
                                                                    .toString()
                                                                    .split(
                                                                        ':')[1]
                                                                    .toString();
                                                          }
                                                        },
                                                      );
                                                      controll_memo
                                                          .settimeminute(
                                                              int.parse(hour),
                                                              int.parse(minute),
                                                              '',
                                                              '');
                                                      pushalarmsettingmemo(
                                                          context,
                                                          setalarmhourNode,
                                                          setalarmminuteNode,
                                                          hour,
                                                          minute,
                                                          '',
                                                          '',
                                                          fToast);
                                                    },
                                                    icon: Container(
                                                      alignment:
                                                          Alignment.center,
                                                      width: 30,
                                                      height: 30,
                                                      child: NeumorphicIcon(
                                                        Icons.settings,
                                                        size: 30,
                                                        style: NeumorphicStyle(
                                                            shape:
                                                                NeumorphicShape
                                                                    .convex,
                                                            depth: 2,
                                                            surfaceIntensity:
                                                                0.5,
                                                            color: TextColor(),
                                                            lightSource:
                                                                LightSource
                                                                    .topLeft),
                                                      ),
                                                    )),
                                                color: TextColor()),
                                          ],
                                        ))),
                              ],
                            )),
                      ],
                    ),
                  )),
              ADBox(),
              Flexible(
                  fit: FlexFit.tight,
                  child: SizedBox(
                    child: ScrollConfiguration(
                      behavior: NoBehavior(),
                      child: SingleChildScrollView(
                          controller: _scrollController,
                          physics: const ScrollPhysics(),
                          child: StatefulBuilder(
                              builder: (_, StateSetter setState) {
                            return Padding(
                              padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  GetBuilder<memosetting>(builder: (_) {
                                    return controll_memo
                                                .ischeckedpushmemoalarm ==
                                            false
                                        ? Column(
                                            children: [
                                              SetRoom(),
                                              const SizedBox(
                                                height: 20,
                                              ),
                                            ],
                                          )
                                        : const SizedBox();
                                  }),
                                  listy_My(),
                                ],
                              ),
                            );
                          })),
                    ),
                  )),
            ],
          )),
    );
  }

  ADBox() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ADEvents(context),
        const SizedBox(
          height: 10,
        ),
      ],
    );
  }

  SetRoom() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.6,
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: contentTitleTextsize(),
                      color: Colors.blue,
                      letterSpacing: 2),
                  text: '알림설정',
                ),
                TextSpan(
                  style: TextStyle(
                      fontWeight: FontWeight.normal,
                      fontSize: contentTextsize(),
                      color: TextColor(),
                      letterSpacing: 2),
                  text: '을 통해 매일 메모 알림을 받아보세요',
                ),
              ],
            ),
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        ListTile(
          dense: true,
          minLeadingWidth: 30,
          horizontalTitleGap: 10,
          leading: Icon(
            Icons.notification_add,
            color: Colors.yellow.shade400,
          ),
          onTap: () async {
            //alarm 설정시트 띄우기
            await firestore.collection('MemoAllAlarm').doc(usercode).get().then(
              (value) {
                hour = value
                    .data()!['alarmtime']
                    .toString()
                    .split(':')[0]
                    .toString();
                minute = value
                    .data()!['alarmtime']
                    .toString()
                    .split(':')[1]
                    .toString();
                print(hour + ':' + minute);
              },
            );
            controll_memo.settimeminute(
                int.parse(hour), int.parse(minute), '', '');
            pushalarmsettingmemo(context, setalarmhourNode, setalarmminuteNode,
                hour, minute, '', '', fToast);

            /*Get.to(
                () => SecureAuth(
                    string: '지문',
                    id: id,
                    doc_secret_bool: doc,
                    doc_pin_number: doc_pin_number,
                    unlock: false),
                transition: Transition.downToUp);*/
          },
          trailing:
              Icon(Icons.keyboard_arrow_right, color: Colors.grey.shade400),
          title: Text('알람 설정하러가기',
              style: TextStyle(
                  color: TextColor(),
                  fontWeight: FontWeight.bold,
                  fontSize: contentTitleTextsize())),
        ),
        const SizedBox(
          height: 10,
        ),
        Divider(
          height: 20,
          color: Colors.grey.shade400,
          thickness: 0.5,
          indent: 30.0,
          endIndent: 0,
        ),
      ],
    );
  }

  listy_My() {
    String realusername = '';
    return StatefulBuilder(builder: (_, StateSetter setState) {
      return GetBuilder<memosetting>(
          builder: (_) => StreamBuilder<QuerySnapshot>(
                stream: firestore
                    .collection('MemoDataBase')
                    .where('OriginalUser', isEqualTo: usercode)
                    .orderBy('EditDate',
                        descending: controll_memo.sort == 0 ? true : false)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return snapshot.data!.docs.isEmpty
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Center(
                                child: NeumorphicText(
                                  '생성된 메모가 없습니다.\n추가 버튼으로 생성해보세요~',
                                  style: NeumorphicStyle(
                                    shape: NeumorphicShape.flat,
                                    depth: 3,
                                    color: TextColor(),
                                  ),
                                  textStyle: NeumorphicTextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: contentTitleTextsize(),
                                  ),
                                ),
                              )
                            ],
                          )
                        : GridView.builder(
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    childAspectRatio: 3 / 6,
                                    mainAxisSpacing: 10,
                                    crossAxisSpacing: 10),
                            physics: const BouncingScrollPhysics(),
                            scrollDirection: Axis.vertical,
                            shrinkWrap: true,
                            itemCount: snapshot.data!.docs.length,
                            padding: const EdgeInsets.only(left: 5, right: 5),
                            itemBuilder: (context, index) {
                              tmpsummary = '';
                              if (snapshot.data!.docs[index]['memolist'] !=
                                  null) {
                                for (String textsummarytmp
                                    in snapshot.data!.docs[index]['memolist']) {
                                  tmpsummary += textsummarytmp + '\n';
                                }
                              } else {
                                tmpsummary = '홈에서 직접 생성한 메모장입니다.';
                              }

                              textsummary.insert(index, tmpsummary);
                              return Column(
                                children: [
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  GestureDetector(
                                      child: FocusedMenuHolder(
                                    menuItems: [
                                      FocusedMenuItem(
                                          trailingIcon: const Icon(
                                            Icons.style,
                                            size: 30,
                                          ),
                                          title: Text('카드정보',
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: contentTextsize())),
                                          onPressed: () async {
                                            //카드별 설정 ex.공유자 권한설정
                                            await firestore
                                                .collection('User')
                                                .where('code',
                                                    isEqualTo: snapshot
                                                            .data!.docs[index]
                                                        ['OriginalUser'])
                                                .get()
                                                .then(
                                              (value) {
                                                realusername =
                                                    value.docs[0]['subname'];
                                              },
                                            );
                                            memoinfo(
                                              index,
                                              snapshot.data!.docs[index].id,
                                              snapshot.data!.docs[index]
                                                  ['Date'],
                                              snapshot.data!.docs[index]
                                                  ['EditDate'],
                                              snapshot.data!.docs[index]
                                                  ['memoTitle'],
                                              context,
                                              realusername,
                                              snapshot.data!.docs[index]
                                                  ['Collection'],
                                            );
                                          }),
                                      FocusedMenuItem(
                                          trailingIcon: Icon(
                                            snapshot.data!.docs[index]
                                                        ['alarmok'] ==
                                                    false
                                                ? Icons.notifications_off
                                                : Icons.notifications_active,
                                            color: snapshot.data!.docs[index]
                                                        ['alarmok'] ==
                                                    false
                                                ? Colors.black
                                                : Colors.yellow.shade400,
                                          ),
                                          title: Text(
                                              snapshot.data!.docs[index]
                                                          ['alarmok'] ==
                                                      false
                                                  ? '알람On'
                                                  : '알람Off',
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: contentTextsize())),
                                          onPressed: () {
                                            setState(() {
                                              controll_memo.settimeminute(
                                                  int.parse(snapshot.data!
                                                      .docs[index]['alarmtime']
                                                      .toString()
                                                      .split(':')[0]),
                                                  int.parse(snapshot.data!
                                                      .docs[index]['alarmtime']
                                                      .toString()
                                                      .split(':')[1]),
                                                  snapshot.data!.docs[index]
                                                      ['memoTitle'],
                                                  snapshot
                                                      .data!.docs[index].id);
                                              pushalarmsettingmemo(
                                                  context,
                                                  setalarmhourNode,
                                                  setalarmminuteNode,
                                                  snapshot.data!
                                                      .docs[index]['alarmtime']
                                                      .toString()
                                                      .split(':')[0],
                                                  snapshot.data!
                                                      .docs[index]['alarmtime']
                                                      .toString()
                                                      .split(':')[1],
                                                  snapshot.data!.docs[index]
                                                      ['memoTitle'],
                                                  snapshot.data!.docs[index].id,
                                                  fToast);
                                            });
                                          }),
                                      FocusedMenuItem(
                                          trailingIcon: Icon(
                                            snapshot.data!.docs[index]
                                                        ['homesave'] ==
                                                    false
                                                ? Icons.launch
                                                : Icons.block,
                                            color: snapshot.data!.docs[index]
                                                        ['homesave'] ==
                                                    false
                                                ? Colors.blue.shade400
                                                : Colors.red.shade400,
                                          ),
                                          title: Text(
                                              snapshot.data!.docs[index]
                                                          ['homesave'] ==
                                                      false
                                                  ? '내보내기'
                                                  : '내보내기 중단',
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: contentTextsize())),
                                          onPressed: () {
                                            setState(() {
                                              snapshot.data!.docs[index]
                                                          ['homesave'] ==
                                                      false
                                                  ? firestore
                                                      .collection(
                                                          'MemoDataBase')
                                                      .doc(snapshot
                                                          .data!.docs[index].id)
                                                      .update({
                                                      'homesave': true,
                                                    })
                                                  : firestore
                                                      .collection(
                                                          'MemoDataBase')
                                                      .doc(snapshot
                                                          .data!.docs[index].id)
                                                      .update({
                                                      'homesave': false,
                                                    });
                                            });
                                          }),
                                      FocusedMenuItem(
                                          trailingIcon: Icon(
                                            snapshot.data!.docs[index]
                                                        ['security'] ==
                                                    false
                                                ? Icons.lock_open
                                                : Icons.lock,
                                            color: snapshot.data!.docs[index]
                                                        ['security'] ==
                                                    false
                                                ? Colors.blue.shade400
                                                : Colors.red.shade400,
                                          ),
                                          title: Text(
                                              snapshot.data!.docs[index]
                                                          ['security'] ==
                                                      false
                                                  ? '잠금설정'
                                                  : '잠금해제',
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: contentTextsize())),
                                          onPressed: () {
                                            setState(() {
                                              //하단 시트로 지문, 얼굴인식 로직 띄우기
                                              settingsecurityform(
                                                  context,
                                                  snapshot.data!.docs[index].id,
                                                  snapshot.data!.docs[index]
                                                      ['security'],
                                                  snapshot.data!.docs[index]
                                                      ['pinnumber'],
                                                  snapshot.data!.docs[index]
                                                      ['securewith'],
                                                  can_auth);
                                            });
                                          }),
                                    ],
                                    duration: const Duration(seconds: 0),
                                    animateMenuItems: true,
                                    menuOffset: 20,
                                    bottomOffsetHeight: 10,
                                    menuWidth:
                                        (MediaQuery.of(context).size.width -
                                                50) /
                                            1.5,
                                    openWithTap: false,
                                    onPressed: () async {
                                      //개별 노트로 이동로직
                                      if (snapshot.data!.docs[index]
                                                  ['security'] ==
                                              false ||
                                          snapshot.data!.docs[index]
                                                  ['securewith'] ==
                                              999) {
                                        Get.to(
                                            () => ClickShowEachNote(
                                                  date: snapshot.data!
                                                      .docs[index]['Date'],
                                                  doc: snapshot
                                                      .data!.docs[index].id,
                                                  doccollection:
                                                      snapshot.data!.docs[index]
                                                              ['Collection'] ??
                                                          '',
                                                  doccolor: snapshot.data!
                                                      .docs[index]['color'],
                                                  doccolorfont: snapshot.data!
                                                      .docs[index]['colorfont'],
                                                  docindex:
                                                      snapshot.data!.docs[index]
                                                              ['memoindex'] ??
                                                          [],
                                                  docname: snapshot.data!
                                                      .docs[index]['memoTitle'],
                                                  docsummary:
                                                      snapshot.data!.docs[index]
                                                              ['memolist'] ??
                                                          [],
                                                  editdate: snapshot.data!
                                                      .docs[index]['EditDate'],
                                                  image:
                                                      snapshot.data!.docs[index]
                                                              ['photoUrl'] ??
                                                          [],
                                                  securewith:
                                                      snapshot.data!.docs[index]
                                                              ['securewith'] ??
                                                          999,
                                                  isfromwhere: 'memohome',
                                                ),
                                            transition: Transition.downToUp);
                                      } else if (snapshot.data!.docs[index]
                                              ['securewith'] ==
                                          0) {
                                        if (GetPlatform.isAndroid) {
                                          final reloadpage = await Get.to(
                                              () => SecureAuth(
                                                  string: '지문',
                                                  id: snapshot
                                                      .data!.docs[index].id,
                                                  doc_secret_bool: snapshot
                                                      .data!
                                                      .docs[index]['security'],
                                                  doc_pin_number: snapshot.data!
                                                      .docs[index]['pinnumber'],
                                                  unlock: true),
                                              transition: Transition.downToUp);
                                          if (reloadpage != null &&
                                              reloadpage == true) {
                                            Get.to(
                                                () => ClickShowEachNote(
                                                      date: snapshot.data!
                                                          .docs[index]['Date'],
                                                      doc: snapshot
                                                          .data!.docs[index].id,
                                                      doccollection: snapshot
                                                                  .data!
                                                                  .docs[index]
                                                              ['Collection'] ??
                                                          '',
                                                      doccolor: snapshot.data!
                                                          .docs[index]['color'],
                                                      doccolorfont: snapshot
                                                              .data!.docs[index]
                                                          ['colorfont'],
                                                      docindex: snapshot.data!
                                                                  .docs[index]
                                                              ['memoindex'] ??
                                                          [],
                                                      docname: snapshot
                                                              .data!.docs[index]
                                                          ['memoTitle'],
                                                      docsummary: snapshot.data!
                                                                  .docs[index]
                                                              ['memolist'] ??
                                                          [],
                                                      editdate: snapshot
                                                              .data!.docs[index]
                                                          ['EditDate'],
                                                      image: snapshot.data!
                                                                  .docs[index]
                                                              ['photoUrl'] ??
                                                          [],
                                                      securewith: snapshot.data!
                                                                  .docs[index]
                                                              ['securewith'] ??
                                                          999,
                                                      isfromwhere: 'memohome',
                                                    ),
                                                transition:
                                                    Transition.downToUp);
                                          }
                                        } else {
                                          final reloadpage = await Get.to(
                                              () => SecureAuth(
                                                  string: '얼굴',
                                                  id: snapshot
                                                      .data!.docs[index].id,
                                                  doc_secret_bool: snapshot
                                                      .data!
                                                      .docs[index]['security'],
                                                  doc_pin_number: snapshot.data!
                                                      .docs[index]['pinnumber'],
                                                  unlock: true),
                                              transition: Transition.downToUp);
                                          if (reloadpage != null &&
                                              reloadpage == true) {
                                            Get.to(
                                                () => ClickShowEachNote(
                                                      date: snapshot.data!
                                                          .docs[index]['Date'],
                                                      doc: snapshot
                                                          .data!.docs[index].id,
                                                      doccollection: snapshot
                                                                  .data!
                                                                  .docs[index]
                                                              ['Collection'] ??
                                                          '',
                                                      doccolor: snapshot.data!
                                                          .docs[index]['color'],
                                                      doccolorfont: snapshot
                                                              .data!.docs[index]
                                                          ['colorfont'],
                                                      docindex: snapshot.data!
                                                                  .docs[index]
                                                              ['memoindex'] ??
                                                          [],
                                                      docname: snapshot
                                                              .data!.docs[index]
                                                          ['memoTitle'],
                                                      docsummary: snapshot.data!
                                                                  .docs[index]
                                                              ['memolist'] ??
                                                          [],
                                                      editdate: snapshot
                                                              .data!.docs[index]
                                                          ['EditDate'],
                                                      image: snapshot.data!
                                                                  .docs[index]
                                                              ['photoUrl'] ??
                                                          [],
                                                      securewith: snapshot.data!
                                                                  .docs[index]
                                                              ['securewith'] ??
                                                          999,
                                                      isfromwhere: 'memohome',
                                                    ),
                                                transition:
                                                    Transition.downToUp);
                                          }
                                        }
                                      } else {
                                        final reloadpage = await Get.to(
                                            () => SecureAuth(
                                                string: '핀',
                                                id: snapshot
                                                    .data!.docs[index].id,
                                                doc_secret_bool: snapshot.data!
                                                    .docs[index]['security'],
                                                doc_pin_number: snapshot.data!
                                                    .docs[index]['pinnumber'],
                                                unlock: true),
                                            transition: Transition.downToUp);
                                        if (reloadpage != null &&
                                            reloadpage == true) {
                                          Get.to(
                                              () => ClickShowEachNote(
                                                    date: snapshot.data!
                                                        .docs[index]['Date'],
                                                    doc: snapshot
                                                        .data!.docs[index].id,
                                                    doccollection: snapshot
                                                                .data!
                                                                .docs[index]
                                                            ['Collection'] ??
                                                        '',
                                                    doccolor: snapshot.data!
                                                        .docs[index]['color'],
                                                    doccolorfont: snapshot
                                                            .data!.docs[index]
                                                        ['colorfont'],
                                                    docindex: snapshot.data!
                                                                .docs[index]
                                                            ['memoindex'] ??
                                                        [],
                                                    docname: snapshot
                                                            .data!.docs[index]
                                                        ['memoTitle'],
                                                    docsummary: snapshot.data!
                                                                .docs[index]
                                                            ['memolist'] ??
                                                        [],
                                                    editdate: snapshot
                                                            .data!.docs[index]
                                                        ['EditDate'],
                                                    image: snapshot
                                                            .data!.docs[index]
                                                        ['photoUrl'],
                                                    securewith: snapshot.data!
                                                                .docs[index]
                                                            ['securewith'] ??
                                                        999,
                                                    isfromwhere: 'memohome',
                                                  ),
                                              transition: Transition.downToUp);
                                        }
                                      }
                                    },
                                    child: Stack(
                                      children: [
                                        ContainerDesign(
                                            child: SizedBox(
                                                height: 260,
                                                width: (MediaQuery.of(context)
                                                            .size
                                                            .width -
                                                        80) /
                                                    2,
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 10, right: 10),
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.end,
                                                    children: [
                                                      SizedBox(
                                                          height: 60,
                                                          child:
                                                              SingleChildScrollView(
                                                            scrollDirection:
                                                                Axis.vertical,
                                                            physics:
                                                                const BouncingScrollPhysics(),
                                                            child: Text(
                                                              snapshot.data!
                                                                          .docs[
                                                                      index]
                                                                  ['memoTitle'],
                                                              maxLines: 2,
                                                              softWrap: true,
                                                              style: TextStyle(
                                                                color:
                                                                    TextColor(),
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize:
                                                                    contentTitleTextsize(),
                                                              ),
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                            ),
                                                          )),
                                                    ],
                                                  ),
                                                )),
                                            color: BGColor()),
                                        SizedBox(
                                          height: 200,
                                          width: (MediaQuery.of(context)
                                                      .size
                                                      .width -
                                                  40) /
                                              2,
                                          child: ContainerDesign(
                                              child: Column(
                                                children: [
                                                  Flexible(
                                                      fit: FlexFit.tight,
                                                      child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .only(
                                                                  left: 10,
                                                                  right: 10),
                                                          child: Column(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              SizedBox(
                                                                height: 110,
                                                                child: snapshot
                                                                            .data!
                                                                            .docs[index]['security'] ==
                                                                        false
                                                                    ? Text(
                                                                        textsummary[
                                                                            index],
                                                                        softWrap:
                                                                            true,
                                                                        maxLines:
                                                                            3,
                                                                        style:
                                                                            TextStyle(
                                                                          color: Color(snapshot
                                                                              .data!
                                                                              .docs[index]['colorfont']),
                                                                          fontWeight:
                                                                              FontWeight.bold,
                                                                          fontSize:
                                                                              contentTextsize(),
                                                                        ),
                                                                        overflow:
                                                                            TextOverflow.ellipsis,
                                                                      )
                                                                    : Container(
                                                                        alignment:
                                                                            Alignment.center,
                                                                        child:
                                                                            NeumorphicIcon(
                                                                          Icons
                                                                              .lock,
                                                                          size:
                                                                              50,
                                                                          style: NeumorphicStyle(
                                                                              shape: NeumorphicShape.convex,
                                                                              depth: 2,
                                                                              surfaceIntensity: 0.5,
                                                                              color: Color(snapshot.data!.docs[index]['colorfont']),
                                                                              lightSource: LightSource.topLeft),
                                                                        ),
                                                                      ),
                                                              ),
                                                            ],
                                                          ))),
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment.end,
                                                    children: [
                                                      RotatedBox(
                                                        quarterTurns: 0,
                                                        child: TextButton.icon(
                                                          style: TextButton
                                                              .styleFrom(
                                                            textStyle: TextStyle(
                                                                color: Color(snapshot
                                                                        .data!
                                                                        .docs[index]
                                                                    [
                                                                    'colorfont'])),
                                                            backgroundColor: snapshot
                                                                            .data!
                                                                            .docs[index]
                                                                        [
                                                                        'color'] !=
                                                                    null
                                                                ? Color(snapshot
                                                                        .data!
                                                                        .docs[index]
                                                                    ['color'])
                                                                : Colors.white,
                                                            shape:
                                                                RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          24.0),
                                                            ),
                                                          ),
                                                          onPressed: () => {},
                                                          icon: Icon(
                                                              Icons.local_offer,
                                                              color: Color(snapshot
                                                                          .data!
                                                                          .docs[
                                                                      index][
                                                                  'colorfont'])),
                                                          label: Text(
                                                            snapshot.data!.docs[
                                                                        index][
                                                                    'Collection'] ??
                                                                '지정안됨',
                                                            softWrap: true,
                                                            maxLines: 2,
                                                            style: TextStyle(
                                                              color: Color(snapshot
                                                                          .data!
                                                                          .docs[
                                                                      index][
                                                                  'colorfont']),
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize:
                                                                  contentTextsize(),
                                                            ),
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          ),
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                ],
                                              ),
                                              color: snapshot.data!.docs[index]
                                                          ['color'] !=
                                                      null
                                                  ? Color(snapshot.data!
                                                      .docs[index]['color'])
                                                  : Colors.white),
                                        ),
                                      ],
                                    ),
                                  ))
                                ],
                              );
                            });
                  } else if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Center(child: CircularProgressIndicator())
                      ],
                    );
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Center(
                        child: NeumorphicText(
                          '생성된 메모컬렉션이 없습니다.\n추가 버튼으로 생성해보세요~',
                          style: NeumorphicStyle(
                            shape: NeumorphicShape.flat,
                            depth: 3,
                            color: TextColor(),
                          ),
                          textStyle: NeumorphicTextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: contentTitleTextsize(),
                          ),
                        ),
                      )
                    ],
                  );
                },
              ));
    });
  }
}
