#-----------------------------------------------------------
# �f�B���N�g�����̃t�@�C������|
#-----------------------------------------------------------
sub do_rmtree{

# �錾
my($type,$rmtree_directory) = @_;
my($updirectory_num);
use File::Path;

# ���^�[��
$updirectory_num =~ ($rmtree_directory =~ s/\.\.\//$&/g);
if($dot_num >= 4){ return; }
if($rmtree_directory eq ""){ return; }
if($rmtree_directory =~ /^\//){ return; }

# �w����!�x�f�B���N�g�����̃t�@�C������|[
rmtree("/var/www/$server_domain/public_html/$rmtree_directory");

# �f�B���N�g�����쐬
mkdir($rmtree_directory,$dirpms);

}

1;
