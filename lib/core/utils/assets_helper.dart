import '../values/app_constants.dart';

/// 资源路径辅助类，用于统一管理应用资源路径
class AssetsHelper {
  // 图片资源
  static String image(String name) => '${AppConstants.IMAGES_PATH}$name.png';

  // 图标资源
  static String icon(String name) => '${AppConstants.ICONS_PATH}$name.svg';

  // 预定义资源路径
  static final String gridBackground = image('grid_background');
  static final String openBook = image('open_book');
  static final String pencil = image('pencil');
  static final String notebook = icon('notebook');
  static final String bell = icon('bell');
  static final String trophy = icon('trophy');
  static final String beer = icon('beer');
  static final String crown = icon('crown');
  static final String smiley = icon('smiley');
  static final String gameboy = icon('gameboy');
  static final String studyCharacter = icon('study_character');
  static final String star = icon('star');
  static final String thumbsUp = icon('thumbs_up');
}
