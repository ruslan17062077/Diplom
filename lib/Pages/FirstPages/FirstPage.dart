import 'package:flutter/material.dart';
import 'package:molokosbor/Themes/ThemeProvider.dart';
import 'package:provider/provider.dart';
import 'package:story_view/story_view.dart';
// ignore: prefer_const_constructors

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text('МолокоСбор')),
        actions: [],
      ),
      
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Обучающие истории
         
          // Первая секция: Информационные блоки
          const Text(
            "Информация",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Container(
            height: 300,
            child: const BasicInfoSection(),
          ),
          const SizedBox(height: 24),
          const Text(
            "Что нужно для правильной сдачи",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Container(
            height: 420,
            child: const Preparation(),
          ),

          const Text(
            "Лайфхаки",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Container(
            height: 420,
            child: const UsefulInfoSection(),
          ),
        ],
      ),
    );
  }
}

/// Виджет с обучающими историями, реализованный с помощью библиотеки story_view.
class TutorialStoriesWidget extends StatefulWidget {
  const TutorialStoriesWidget({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _TutorialStoriesWidgetState createState() => _TutorialStoriesWidgetState();
}

class _TutorialStoriesWidgetState extends State<TutorialStoriesWidget> {
  final StoryController _storyController = StoryController();

  @override
  void dispose() {
    _storyController.dispose();
    super.dispose();
  }

  List<StoryItem> _buildStories() {
    return [
      StoryItem.pageImage(
        url: "https://via.placeholder.com/400x600.png?text=История+1",
        controller: _storyController,
        caption: const Text("Добро пожаловать в МолокоСбор! Начнём обучение."),
      ),
      StoryItem.pageImage(
        url: "https://via.placeholder.com/400x600.png?text=История+2",
        controller: _storyController,
        caption: const Text("Узнайте, как использовать наше приложение."),
      ),
      // Дополнительные истории можно добавить здесь.
    ];
  }

  @override
  Widget build(BuildContext context) {
    return StoryView(
      storyItems: _buildStories(),
      controller: _storyController,
      onComplete: () {
        print("Истории закончились");
      },
      progressPosition: ProgressPosition.top,
      repeat: false,
    );
  }
}

class BasicInfoSection extends StatelessWidget {
  const BasicInfoSection({super.key});

  @override
  Widget build(BuildContext context) {
    return PageView(
      children: const [
        InfoCard(
          title: "О нас",
          description:
              "Мы – команда, стремящаяся улучшить процесс сбора молока в деревнях.",
          imageUrl:
              "https://korenovsk.ru/wp-content/uploads/2023/02/13.02.2023-750x450.jpg",
        ),
        InfoCard(
          title: "У нас 3 сборщика",
          description:
              "Наш коллектив из трёх сборщиков гарантирует быструю и качественную доставку молока.",
          imageUrl:
              "https://mogilevnews.by/sites/default/files/uploaded/dsc06019.jpg",
        ),
        InfoCard(
          title: "Хорошие цены",
          description:
              "Мы предлагаем конкурентные цены и выгодные условия сотрудничества.",
          imageUrl:
              "https://avatars.dzeninfra.ru/get-zen_doc/1945957/pub_63dffd30c30ab522dc334e8c_63e1691b5506c141cd66f6f3/scale_1200",
        ),
      ],
    );
  }
}

class Preparation extends StatelessWidget {
  const Preparation({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PageView(
      children: const [
        InfoCard(
          title: "Гигиена перед сцеживанием",
          description: "1. Вымойте руки с мылом и теплой водой.\n"
              "2. Подготовьте чистую, стерильную ёмкость.\n"
              "3. Убедитесь, что сцеживание проходит в чистом помещении.",
          imageUrl: "https://dutrion.ru/wp-content/uploads/2022/06/4-1.jpg",
        ),
        InfoCard(
          title: "Сцеживание и ёмкости",
          description:
              "1. Используйте стерильную стеклянную или пластиковую ёмкость с крышкой.\n"
              "2. Не трогайте внутреннюю часть сосуда.\n"
              "3. Подпишите ёмкость: дата и время сцеживания.",
          imageUrl: "https://www.golfpanorama.ch/site/assets/files/12079/shutterstock_382685590_1_1.730x730.jpg",
        ),
        InfoCard(
          title: "Хранение молока",
          description:
              "1. Храните молоко в холодильнике при +2…+4°C не более 24 часов.\n"
              "2. Не допускайте многократного охлаждения и нагревания.\n"
              "3 Не замораживайте молоко, если планируете сдачу.",
          imageUrl: "https://sun9-27.userapi.com/impg/sbJXSyDnMUFBLqPiTdiI_bZM9Qu_Q2qKr23WTg/_WDRtKtg0zo.jpg?size=1280x720&quality=95&sign=1dce229ad0c2f5c30ae59a208560c27e&c_uniq_tag=HVyclGMwYkkwEXYRoMGJE5LR16DGmrnK5HjTqrs2PSI&type=album",
        ),
        InfoCard(
          title: "Перевозка молока",
          description: "1. Используйте термосумку с хладоэлементами.\n"
              "2. Доставьте молоко в банк в течение 2 часов после изъятия из холодильника.\n"
              "3. Не допускайте нагрева в дороге.",
          imageUrl: "https://a.d-cd.net/fdc1a3es-1920.jpg",
        ),
        InfoCard(
          title: "Важно помнить",
          description: "1. Не сцеживайте молоко в грязную посуду.\n"
              "2. Не смешивайте молоко из разных дней.\n"
              "3. Не сдавайте молоко, если вы болеете или принимаете запрещённые препараты.",
          imageUrl: "https://gkh.kurganobl.ru/wp-content/uploads/2022/07/25/1621702178_9-phonoteka_org-p-fon-s-vosklitsatelnimi-znakami-12-1.jpg",
        ),
      ],
    );
  }
}

/// Горизонтально листаемая секция с полезной информацией.
class UsefulInfoSection extends StatelessWidget {
  const UsefulInfoSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: PageView(
        children: const [
          InfoCard(
            title: "Лайфхаки",
            description:
                "Советы, как упростить процесс доения и повысить эффективность.",
            imageUrl:
                "https://avatars.mds.yandex.net/get-dialogs/399212/d5882088b28508559b1d/orig",
          ),
          InfoCard(
            title: "Подготовка вымени перед доением",
            description:
                "Перед началом процесса всегда мойте и обрабатывайте вымя тёплой водой с мягким антисептическим раствором. Это снижает риск заражения и помогает коровам расслабиться.",
            imageUrl: "https://dutrion.ru/wp-content/uploads/2022/06/4-1.jpg",
          ),
          InfoCard(
            title: "Создание спокойной атмосферы",
            description:
                "Обеспечьте тихое и комфортное место для доения. Избегайте резких движений и громких звуков, что поможет животным расслабиться и улучшит процесс выделения молока.",
            imageUrl:
                "https://avatars.mds.yandex.net/i?id=fa160e3b551a727072543b3822e6c0db_l-3592543-images-thumbs&n=13",
          ),
          InfoCard(
            title: "Индивидуальный подход к каждой корове",
            description:
                "Обратите внимание на особенности каждой животной особи: некоторые коровы требуют более мягкого обращения, другие лучше реагируют на определённый порядок действий. Ведение индивидуальных карточек может помочь выявить оптимальные методы для каждой особи.",
            imageUrl:
                "https://sun9-43.userapi.com/impg/PfJ2yFxVjXQ_jqxTpUJ5vsfYBGTKj7Sb-9yUXQ/8eGMU4h_hKI.jpg?size=1000x690&quality=96&sign=ecad930c1b849c05c3f638698d069798&c_uniq_tag=N2MlPzqyBEC8SeT3v2DqDazx44f0AH0m6dxtwrACImA&type=album",
          ),
          InfoCard(
            title: "Классическая музыка для коров",
            description:
                "Факт: классическая музыка может положительно влиять на настроение коров и их продуктивность.",
            imageUrl:
                "https://sun9-76.userapi.com/impg/usuKnPmu00JmdR0-C0xbCZpWy_r9iValhDaCzg/5ve5RQhRMJ4.jpg?size=900x506&quality=96&sign=2e5137c37287b1adc40a961ed4cf73b9&c_uniq_tag=cIcpIdPFILhfWMJ5AH7-yokbh62uiIn9OyXOe4b7pl4&type=album",
          ),
        ],
      ),
    );
  }
}
class InfoCard extends StatelessWidget {
  final String title;
  final String description;
  final String imageUrl;

  const InfoCard({
    Key? key,
    required this.title,
    required this.description,
    required this.imageUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Card(
        elevation: theme.cardTheme.elevation,
        color: theme.cardTheme.color, // <-- теперь цвет задаётся из темы
        shape: theme.cardTheme.shape,
        shadowColor: theme.cardTheme.shadowColor,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Заголовок с изображением
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      image: DecorationImage(
                        image: NetworkImage(imageUrl),
                        fit: BoxFit.cover,
                      ),
                      border: Border.all(
                        color: theme.dividerColor,
                        width: 2,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Text(
                  description,
                  style: theme.textTheme.bodyMedium?.copyWith(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
