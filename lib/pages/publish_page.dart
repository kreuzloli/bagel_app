import 'dart:io';

import 'package:bagel_app/models/category.dart';
import 'package:bagel_app/service/api/note_api_service.dart';
import 'package:bagel_app/service/api/system_api_service.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

/// 发布页
class PublishPage extends StatefulWidget {
  const PublishPage({super.key});

  @override
  State<PublishPage> createState() => _PublishPageState();
}

/// 发布页对应的状态类
///
/// 因为图片列表会随着用户操作发生变化，
/// 所以这里不能继续使用 StatelessWidget，
/// 而是要使用 StatefulWidget 来保存和刷新页面状态。
class _PublishPageState extends State<PublishPage> {
  /// 标题输入框控制器
  final TextEditingController _titleController = TextEditingController();

  /// 正文输入框控制器
  final TextEditingController _contentController = TextEditingController();

  /// 标签输入框控制器
  ///
  /// 用户可以输入：
  ///
  /// 美食 探店 北京 或者 美食,探店,北京
  final TextEditingController _tagsController = TextEditingController();

  /// 图片选择器对象
  ///
  /// ImagePicker 是 image_picker 插件提供的工具类。
  /// 它可以帮我们打开系统相册，并拿到用户选择的图片。
  final ImagePicker _imagePicker = ImagePicker();

  /// 笔记 API 服务
  final NoteApiService _noteApiService = NoteApiService();

  /// 系统 API 服务
  final SystemApiService _systemApiService = SystemApiService();

  /// 已选择的图片
  final List<XFile> _selectedImages = [];

  /// 分类列表
  final List<Category> _categories = [];

  /// 当前选中的分类
  Category? _selectedCategory;

  /// 是否正在加载分类
  bool _isLoadingCategories = false;

  /// 是否正在发布
  bool _isPublishing = false;

  @override
  void initState() {
    super.initState();
    // 页面打开时，从 API 读取分类
    _loadCategories();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  /// 显示提示

  void _showMessage(String message) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  /// 加载分类
  Future<void> _loadCategories() async {
    setState(() {
      _isLoadingCategories = true;
    });
    try {
      final List<Category> categories = await _systemApiService
          .fetchCategories();
      if (!mounted) {
        return;
      }
      setState(() {
        _categories.clear();
        _categories.addAll(categories);
        // 默认选中第一个分类
        _selectedCategory = _categories.isNotEmpty
            ? _categories.first
            : _selectedCategory;
      });
    } catch (e) {
      _showMessage('分类加载失败：$e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingCategories = false;
        });
      }
    }
  }

  /// 从相册选择图片
  ///
  /// 这里使用 pickMultiImage 方法，
  /// 它表示可以一次选择多张图片。
  ///
  /// 但是我们的业务规则是最多 9 张，
  /// 所以选择完成后，还要自己做数量限制。
  Future<void> _pickImages() async {
    // 计算当前还能继续选择几张图片。
    final int remainingCount = 9 - _selectedImages.length;
    // 如果已经选满 9 张，就不允许继续选择。
    if (remainingCount <= 0) {
      _showMessage('最多只能选择9张图片');
      return;
    }
    // 打开系统相册，让用户选择多张图片。
    //
    // imageQuality 表示压缩质量。
    // 85 表示尽量保持清晰，同时稍微减少一点图片体积。
    final List<XFile> pickedImages = await _imagePicker.pickMultiImage(
      imageQuality: 85,
    );
    // 如果用户没有选择图片，而是直接取消了相册选择，
    // pickedImages 就会是空列表，这时什么都不做。
    if (pickedImages.isEmpty) {
      return;
    }
    // 只保留还可以加入的图片数量。
    //
    // 比如当前已经有 7 张，还能选 2 张。
    // 如果用户一次选了 5 张，这里只取前 2 张。
    final List<XFile> imagesCanBeAdded = pickedImages
        .take(remainingCount)
        .toList();
    // setState 表示通知 Flutter：
    // 数据变了，请重新执行 build 方法刷新页面。
    setState(() {
      _selectedImages.addAll(imagesCanBeAdded);
    });
    // 如果用户选的图片数量超过剩余可选数量，
    // 给用户一个提示，不然他会以为图片消失了。
    if (pickedImages.length > remainingCount) {
      _showMessage(
        '最多只能选择 9 张图片，已自动保留前 $remainingCount 张',
      );
    }
  }

  /// 打开相机拍照
  ///
  /// 这个方法会调用系统相机。
  /// 用户拍照完成后，会返回一张 XFile 图片。
  ///
  /// 注意：
  /// iPhone / Android 可以正常使用。
  /// 桌面端默认不适合用这个方法。
  Future<void> _takePhoto() async {
    // 先判断图片数量是否已经达到上限。
    if (_selectedImages.length >= 9) {
      _showMessage('最多只能选择 9 张图片');
      return;
    }
    try {
      // 打开系统相机
      final XFile? photo = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );
      // 如果用户取消拍照，photo 会是 null。
      if (photo == null) {
        return;
      }
      // 把拍好的照片加入图片列表，并刷新页面。
      setState(() {
        _selectedImages.add(photo);
      });
    } catch (error) {
      _showMessage('当前设备没有可用相机，请用真机测试拍照功能');
    }
  }

  /// 删除一张已经选择的图片
  ///
  /// index 表示图片在列表中的位置。
  /// 比如 index 是 0，就表示删除第一张图片。
  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  /// 点击发布按钮
  Future<void> _handlePublish() async {
    final String title = _titleController.text.trim();
    final String content = _contentController.text.trim();
    final List<String> tags = _tagsController.text
        .split(RegExp(r'[\s,，#]+'))
        .map((String tag) => tag.trim())
        .where((String tag) => tag.isNotEmpty)
        .toList();

    if (title.isEmpty) {
      _showMessage('标题不能为空');
      return;
    }
    if (content.isEmpty) {
      _showMessage('正文不能为空');
      return;
    }
    if (_selectedCategory == null) {
      _showMessage('分类加载中，请稍后再试');
      return;
    }

    if (_isPublishing) {
      return;
    }

    setState(() {
      _isPublishing = true;
    });

    try {
      await _noteApiService.createNote(
        title: title,
        content: content,
        categoryId: _selectedCategory!.id,
        images: _selectedImages.map((XFile image) => image.path).toList(),
        tags: tags,
      );
      if (!mounted) {
        return;
      }
      _showMessage('发布成功');
      Navigator.pop(context, true);
    } catch (e) {
      _showMessage('发布失败：$e');
    } finally {
      if (mounted) {
        setState(() {
          _isPublishing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        title: const Text(
          '发布笔记',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildImagePickerArea(),
              const SizedBox(height: 20),
              _buildTitleInput(),
              const SizedBox(height: 16),
              _buildContentInput(),
              const SizedBox(height: 16),
              _buildTagsInput(),
              const SizedBox(height: 16),
              _buildCategoryDropdown(),
              const SizedBox(height: 30),
              _buildPublishButton(),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建选择图片区域
  Widget _buildImagePickerArea() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 图片区域顶部标题和数量
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '选择图片',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              // 显示当前已经选择了几张图片
              Text(
                '${_selectedImages.length}/9',
                style: const TextStyle(fontSize: 13, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 12),
          GridView.builder(
            // 因为 GridView 放在 SingleChildScrollView 里面，
            // 所以这里必须设置 shrinkWrap 为 true，
            // 让 GridView 根据内容高度自动撑开。
            shrinkWrap: true,
            // 禁止 GridView 自己滚动。
            // 页面整体交给外层 SingleChildScrollView 滚动。
            physics: const NeverScrollableScrollPhysics(),
            // 如果图片没满 9 张，就多显示一个“添加图片”按钮。
            // 如果已经满 9 张，就只显示 9 张图片，不再显示添加按钮。
            itemCount: _selectedImages.length < 9
                ? _selectedImages.length + 1
                : _selectedImages.length,
            // 设置一行 3 个格子
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemBuilder: (BuildContext context, int index) {
              /// 当 index 等于当前图片数量时，
              /// 说明这个格子不是图片，而是“添加图片”按钮。
              /// 否则就显示对应位置的图片预览。
              final bool isAddButton = index == _selectedImages.length;
              if (isAddButton) {
                return _buildAddImageButton();
              } else {
                return _buildImagePreviewItem(index);
              }
            },
          ),
        ],
      ),
    );
  }

  /// 构建添加图片按钮
  ///
  /// 这个按钮放在图片网格里。
  /// 用户点击它时，会打开系统相册。
  Widget _buildAddImageButton() {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: _showImageSourceSheet,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFFFF1F3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFFFD6DE)),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_photo_alternate_outlined,
              color: Color(0xFFFF4D67),
              size: 30,
            ),
            SizedBox(height: 6),
            Text(
              '添加图片',
              style: TextStyle(fontSize: 12, color: Color(0xFFFF4D67)),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建单张图片预览
  ///
  /// 每一张图片都放在一个 Stack 里面。
  /// Stack 的作用是让多个组件叠在一起。
  /// 这里就是：底下是图片，右上角叠一个删除按钮。
  Widget _buildImagePreviewItem(int index) {
    final XFile imageF = _selectedImages[index];
    return Stack(
      children: [
        // 图片本体
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.file(
            File(imageF.path),
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
        // 右上角删除按钮
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: () => _removeImage(index),
            child: Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: Colors.black.withAlpha(140),
                borderRadius: BorderRadius.circular(11),
              ),
              child: const Icon(Icons.close, size: 15, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  /// 标题输入框
  Widget _buildTitleInput() {
    return TextField(
      controller: _titleController,
      maxLength: 30,
      decoration: const InputDecoration(
        labelText: '标题',
        hintText: '给你的笔记起个标题',
        border: OutlineInputBorder(),
      ),
    );
  }

  /// 正文输入框
  Widget _buildContentInput() {
    return TextField(
      controller: _contentController,
      maxLines: 8,
      decoration: const InputDecoration(
        labelText: '正文',
        hintText: '分享你的内容吧',
        border: OutlineInputBorder(),
        alignLabelWithHint: true,
      ),
    );
  }

  /// 标签输入框

  Widget _buildTagsInput() {
    return TextField(
      controller: _tagsController,
      decoration: const InputDecoration(
        labelText: '标签',
        hintText: '例如：美食 探店 北京',
        border: OutlineInputBorder(),
      ),
    );
  }

  /// 构建发布按钮
  Widget _buildPublishButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        // 点击事件
        onPressed: _isPublishing ? null : _handlePublish,
        style: ElevatedButton.styleFrom(
          // 按钮背景色
          backgroundColor: const Color(0xFFFF4D67),
          // 按钮前景色，也就是文字颜色
          foregroundColor: Colors.white,
          // 去掉阴影
          elevation: 0,
          // 圆角
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
        ),
        child: Text(
          _isPublishing ? '发布中...' : '发布',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  /// 分类下拉框
  Widget _buildCategoryDropdown() {
    if (_isLoadingCategories) {
      return const Row(
        children: [
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          SizedBox(width: 8),
          Text('正在加载分类...'),
        ],
      );
    }
    if (_categories.isEmpty) {
      return Row(
        children: [
          const Expanded(child: Text('暂无分类，请检查分类接口')),
          TextButton(onPressed: _loadCategories, child: const Text('重试')),
        ],
      );
    }

    return DropdownButtonFormField<Category>(
      key: ValueKey(_selectedCategory?.id),
      initialValue: _selectedCategory,
      decoration: const InputDecoration(
        labelText: '分类',
        border: OutlineInputBorder(),
      ),
      items: _categories.map((category) {
        return DropdownMenuItem<Category>(
          value: category,
          child: Text(category.name),
        );
      }).toList(),
      onChanged: (Category? value) {
        setState(() {
          _selectedCategory = value;
        });
      },
    );
  }

  /// 显示图片来源选择菜单
  ///
  /// 用户点击“添加图片”后，
  /// 不再直接打开相册，
  /// 而是先弹出一个底部菜单，
  /// 让用户选择：
  /// 从相册选择，或者直接拍照。
  void _showImageSourceSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 顶部的小横条，纯装饰。
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0E0E0),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  '选择图片来源',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                ListTile(
                  leading: const Icon(
                    Icons.photo_library_outlined,
                    color: Color(0xFFFF4D67),
                  ),
                  title: const Text('从相册选择'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImages();
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.photo_camera_outlined,
                    color: Color(0xFFFF4D67),
                  ),
                  title: const Text('拍照'),
                  onTap: () {
                    Navigator.pop(context);
                    _takePhoto();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
