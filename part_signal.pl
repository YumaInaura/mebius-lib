
#-----------------------------------------------------------
# ���ڃf�[�^���X�V
#-----------------------------------------------------------

sub renew_signal{

# �Ǐ���
my($type,$moto,$category,$num,$res) = @_;
my(@line,$i,$flag,$newkey,$block_flag,$file,$category_hit);

# �����`�F�b�N
if($main::device{'level'} < 1){ $block_flag = qq(���̊��ł͎��s�ł��܂���B); }

# ���o�C���A�C�e���擾
if($type =~ /MOBILE/){ &kget_items; }

# �t�@�C����`
$moto =~ s/\W//;
$category =~ s/\W//;
if($moto eq "" || $category eq ""){ $block_flag = qq(�l���w�肵�Ă��������B); }

# �����^�C�v��`
if($type =~ /SIGNAL/){ $file = "${int_dir}_sinnchaku/peta_signal.cgi"; }
elsif($type =~ /RES/){ $file = "${int_dir}_sinnchaku/peta_res.cgi"; }
elsif($type =~ /POST/){ $file = "${int_dir}_sinnchaku/peta_post.cgi"; }
else{ $block_flag = qq(���s�^�C�v���w�肵�Ă��������B); }

# ���^�[���ƃG���[
if($moto eq "delete" || $secret_mode || $main::bbs{'concept'} =~ /Chat-mode/ || $subtopic_mode){ $block_flag = qq(���̌f���ł͎��s�ł��܂���B); }
if($home eq "http://mb2.jp/" && $server_domain eq "aurasoul.mb2.jp"){ $block_flag = qq(���̌f���ł͎��s�ł��܂���B); }
if($block_flag && $type =~ /SIGNAL/){ &error("$block_flag"); }
elsif($block_flag){ return; }

# �A�����M�֎~
if($type =~ /SIGNAL/){ &redun("SIGNAL",60); }

# �L�[��`
$newkey = 1;

# �ǉ�����s
push(@line,"$newkey<>$moto<>$time<>$category<>$num<>$res<>\n"); $category_hit++;

# �t�@�C�����J��
open(FILE_IN,"$file");
while(<FILE_IN>){
$i++;
chomp;
my($key,$moto2,$lasttime,$category2) = split(/<>/);
if($i > 10){ last; }
if($moto2 eq $moto){ next; }
if($category2 eq $category){ $category_hit++; if($category_hit > 3){ next; } }
push(@line,"$_\n");
}
close(FILE_IN);

# �t�@�C�����X�V
open(FILE_OUT,">$file");
print FILE_OUT @line;
close(FILE_OUT);
Mebius::Chmod(undef,"$file");

	# ���[�h
	if($type =~ /RES/ || $type =~ /POST/){ return; }


# �I��
exit;


}


#-----------------------------------------------------------
# ���ڃf�[�^���擾
#-----------------------------------------------------------
sub get_signal{

my($line,$type) = @_;
my($hit,$class,$class2,$max,$file,$keeptime);

	# ���o�C���A�C�e���擾
	if($type =~ /MOBILE/){ &kget_items; }

	# �^�C�v����
	if($type =~ /SIGNAL/){
		$class = qq( class="signal");
		$file = "${int_dir}_sinnchaku/peta_signal.cgi";
		$max = 1;
		$keeptime = 24*60*60;
	}

	# �^�C�v����
	if($type =~ /RES/){
		$class = qq( class="star1");
		$file = "${int_dir}_sinnchaku/peta_res.cgi";
		$max = 4;
		$keeptime = 1*60*60;
	}

	# �^�C�v����
	if($type =~ /POST/){
		$class = qq( class="star4");
		$file = "${int_dir}_sinnchaku/peta_post.cgi";
		$max = 2;
		$keeptime = 12*60*60;
	}

	if($type =~ /MOBILE/){ }
	else{ $class2 = qq( class="star3"); }

# �t�@�C�����J��
open(FILE_IN,"<$file");
	while(<FILE_IN>){
		chomp;
		my($key,$moto2,$lasttime,$category2,$num,$res) = split(/<>/);
		my($icon);

			if($time > $lasttime + $keeptime){ next; }

			# �A�C�R��
			if($type =~ /SIGNAL/){
					if($type =~ /MOBILE/){ $icon = qq(<span style="color:#080;font-size:small;">��</span>); }
					else{ $icon = qq( <img src="/pct/star_signal.gif" alt="�V�O�i��">); }
			}

			# �A�C�R��
			if($type =~ /RES/){
					if($type =~ /MOBILE/){ $icon = qq(<span style="color:#f00;font-size:small;">��</span>); }
					else{ $icon = qq( <span class="res_star">��</span>); }
					#else{ $icon = qq( <a href="_$moto2/$num.html#S$res" class="res_star">��</a>); }
			}

			# �A�C�R��
			if($type =~ /POST/){
					if($type =~ /MOBILE/){ $icon = qq(<span style="color:#f00;font-size:small;">����</span>); }
					else{ $icon = qq( <span class="post_star">����</span>); }
					#else{ $icon = qq( <a href="_$moto2/$num.html" class="post_star">����</a>); }
			}

		#if($max >= 5 && $hit >= $max*0.5){ $line =~ s/<a href="_$moto2\/">(.+?)<\/a>/<a href="_$moto2\/"$class2>$1<\/a>/g; }

		$line =~ s/<a href="_$moto2\/">(.+?)<\/a>/<a href="_$moto2\/"$class>$1<\/a>$icon/g;

		$hit++;

			if($hit >= $max){ last; }


	}
close(FILE_IN);

return($line);

}


1;

