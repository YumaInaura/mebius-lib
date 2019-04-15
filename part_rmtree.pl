#-----------------------------------------------------------
# ディレクトリ内のファイルを一掃
#-----------------------------------------------------------
sub do_rmtree{

# 宣言
my($type,$rmtree_directory) = @_;
my($updirectory_num);
use File::Path;

# リターン
$updirectory_num =~ ($rmtree_directory =~ s/\.\.\//$&/g);
if($dot_num >= 4){ return; }
if($rmtree_directory eq ""){ return; }
if($rmtree_directory =~ /^\//){ return; }

# 『注意!』ディレクトリ内のファイルを一掃[
rmtree("/var/www/$server_domain/public_html/$rmtree_directory");

# ディレクトリを作成
mkdir($rmtree_directory,$dirpms);

}

1;
