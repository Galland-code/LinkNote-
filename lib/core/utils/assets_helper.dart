import '../values/app_constants.dart';

/// 资源路径辅助类，用于统一管理应用资源路径
class AssetsHelper {
  // 图片资源
  static String image(String name) => '${AppConstants.IMAGES_PATH}$name.png';

  // 图标资源
  static String icon(String name) => '${AppConstants.ICONS_PATH}$name.png';

  // 预定义资源路径
  static final String gridBackground = image('grid_background');
  static final String openBook = image('open_book');
  static final String pencil = image('pencil');
  static final String notebook = image('notebook');
  static final String bell = image('bell');
  static final String trophy = image('trophy');
  static final String beer = image('beer');
  static final String crown = image('crown');
  static final String smiley = image('smiley');
  static final String gameboy = image('gameboy');
  static final String studyCharacter = image('study_character');
  static final String star = image('star');
  static final String thumbsUp = image('thumbs_up');
}
