import 'package:chatview/chatview.dart';

class Data {
  static const profileImage =
      "https://raw.githubusercontent.com/SimformSolutionsPvtLtd/flutter_showcaseview/master/example/assets/simform.png";
  static final messageList = [
    Message(
      id: '1',
      message: "Hi!",
      createdAt: DateTime.now(),
      sendBy: '1', // userId of who sends the message
    ),
    Message(
      id: '2',
      message: "Hi!",
      createdAt: DateTime.now(),
      sendBy: '2',
    ),
    Message(
      id: '3',
      message: "We can meet?I am free",
      createdAt: DateTime.now(),
      sendBy: '1',
    ),
    Message(
      id: '4',
      message: "Can you write the time and place of the meeting?",
      createdAt: DateTime.now(),
      sendBy: '1',
    ),
    Message(
      id: '5',
      message: "That's fine",
      createdAt: DateTime.now(),
      sendBy: '2',
      reaction: Reaction(reactions: ['❤️'], reactedUserIds: ['1']),
    ),
    Message(
      id: '6',
      message: "https://bit.ly/3JHS2Wl",
      createdAt: DateTime.now(),
      sendBy: '2',
      replyMessage: const ReplyMessage(
        message: "Can you write the time and place of the meeting?",
        replyTo: '1',
        replyBy: '2',
        messageId: '4'
      ),
    ),
    Message(
      id: '7',
      message: "Done",
      createdAt: DateTime.now(),
      sendBy: '1',
    ),
    Message(
      id: '8',
      message: "Thank you!!",
      createdAt: DateTime.now(),
      sendBy: '1',
    ),
    Message(
      id: '9',
      message:
          "https://bs-uploads.toptal.io/blackfish-uploads/components/seo/content/og_image_file/og_image/777695/0408-FlutterMessangerDemo-Luke_Social-e8a0e8ddab86b503a125ebcad823c583.png",
      createdAt: DateTime.now(),
      messageType: MessageType.image,
      sendBy: '1',
      reaction: Reaction(
        reactions: ['❤️', '👍',],
        reactedUserIds: ['2', '3',],
      ),
    ),
    Message(
      id: '10',
      message: "🤩🤩",
      createdAt: DateTime.now(),
      sendBy: '2',
    ),
    Message(
      id: '11',
      message: "https://dl.espressif.com/dl/audio/ff-16b-2c-44100hz.aac",
      createdAt: DateTime.now(),
      sendBy: '2',
      messageType: MessageType.audio,
      fileType: 'acc',
    ),
    Message(
      id: '12',
      message:
      "https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4",
      createdAt: DateTime.now(),
      messageType: MessageType.video,
      sendBy: '2',
      fileType: 'mp4',
    ),
    Message(
      id: '13',
      message:
      "https://www.orimi.com/pdf-test.pdf",
      createdAt: DateTime.now(),
      messageType: MessageType.file,
      sendBy: '2',
      fileType: 'pdf',
    ),
  ];
}
