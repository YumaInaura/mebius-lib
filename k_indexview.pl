
package main;

#-----------------------------------------------------------
# �g�єŃC���f�b�N�X
#-----------------------------------------------------------
sub bbs_view_indexview_mobile{

# �錾
my($type,$join_parts) = @_;
my($num,$sub,$res,$nam,$date,$na2,$key,$alarm,$i,$data,$top,$count);
my($file,$newrgt,$follow_link,$index_handler,$hit,$index_line,$hit,$kadsense_view,$prnt);
our($kfontsize_xsmall_in);

my(%emoji) = Mebius::Emoji;
my($emoji_shift_jis) = Mebius::Encoding::hash_to_shift_jis(\%emoji);

$time = time;

# �T�u�L����p�̏ꍇ�A���_�C���N�g
if($subtopic_mode && $type =~ /VIEW/){ Mebius::Redirect("","http://$server_domain/_$moto/",301); }

	# �����U�蕪�� ( �������[�h )
	if($main::mode eq "find"){
		my($init_directory) = Mebius::BaseInitDirectory();
		require "${init_directory}k_find.pl";
		&bbs_find_mobile();
	}

$p = $in{'p'};

# �}�C�y�[�W�̖߂��
$mybackurl = "http://$server_domain/_$moto/";

# �i�r�Q�[�V���������N�̐ݒ�
if($in{'p'} eq "" || $in{'p'} eq "0"){ $kboad_link = "now"; }

# �g�ѐݒ�
if(!$join_parts){ &kget_items(); }

# �^�C�g����`
&set_title_kindexview();

# �Ǐ���
my($secret_links,$new_rgt);

# �V�K���e�����N
if($concept !~ /NOT-POST/) { $new_rgt = qq( <a href="kform.html"$sikibetu>�V�K</a>); }

# �t�H���[�����N
if($cookie) { $follow_link = qq( <a href="$script?type=form_follow&amp;k=1">̫۰</a>); }

# �閧�����N
if($secret_mode){
$secret_links = qq(
<span style="font-size:x-small;">
<a href="member.html">�����o</a>
<a href="$script?mode=member&amp;type=vedit"$main::utn2>�ݒ�</a>
<a href="./?mode=logoff"$main::utn2>���O�I�t</a>
</span>
);
}

	# �L��
my($kadsense1,$kadsense2) = &kadsense("INDEX");

	if($kadsense1){
		$kadsense_view = qq(<hr$xclose>$kadsense1);
	}

	if($kadsense2){
		$main::kfooter_ads = $kadsense2;

	}


# HTML
$print .= qq(
$join_parts
<div style="${kfontsize_medium_in}background:#dee;text-align:center;">
$title$secret_links
</div>

<form action="$script" style="$kpadding_normal_in$kborder_top_in"><div style="$ktextalign_center_in">
(*)<input type="hidden" name="mode" value="find"$xclose><input type="text" name="word" value="" size="9" accesskey="*"$xclose><input type="submit" value="����"$xclose>
</div>
</form>
$kadsense_view
);


# ����
if($p eq "") { $p = 0; }
my($i);
$file = $nowfile;


# �t�@�C���ǂݍ���
open($index_handler,"<","$file");
$top = <$index_handler>;
my($newnum,$none) = split(/<>/,$top);

# �e�L�����F���A�y�[�W�J��z�������N���̒���
if($newnum < $i_max){ $i_max = $newnum; }

$print .= qq(<div style="background:#eef;$ktextalign_center_in$kborder_top_in">�i�r</div>);
$print .= qq(<div style="padding:0.5em 0em;$ktextalign_center_in">\n);
$print .= qq($new_rgt$follow_link <a href="$newnum.html">$emoji_shift_jis->{'new'}�L��</a>\n);
	if($main::bbs{'concept'} !~ /Not-handle-ranking/){
		$print .= qq(<a href="./ranking.html">�Q����</a>\n);
	}
$print .= qq(</div>);

# ���j���[�㕔�̑�
$print .= qq(<div style="background:#eef;$ktextalign_center_in$kborder_top_in">$emoji_shift_jis->{'number5'}<a href="#MENU" id="MENU" accesskey="5">�ꗗ</a></div>);

	# �C���f�b�N�X��W�J
	while (<$index_handler>) {

		# �Ǐ���
		my($background_color,$stopic,$link);
		
		# ���E���h�J�E���^
		$i++;

			# ���񏈗��ɉ񂷏ꍇ
			if($_ eq ""){ next; }
			if($i < $p + 1){ next; }
			if($i > $p + $menu1){ next; }

		# �q�b�g�J�E���^
		$hit++;

		# �s�𕪉�
		chomp;
		my($num,$sub,$res,$nam,$date,$lasthandle,$key) = split(/<>/);
		
		require "${main::int_dir}part_indexview.pl";
		my $utf8_data = utf8_return($_);
		($index_line) .= shift_jis(main::indexline_set("Mobile-view",$utf8_data,$hit));

	}

close($index_handler);

$print .= qq($index_line);

$print .= qq(<hr$xclose>);

# �y�[�W�߂��胊���N���擾
my($page_links) = &get_pagelinks_kindexview("Round1",$i);
$print .= $page_links;

# �w�b�_
Mebius::Template::gzip_and_print_all({},$print);

exit;

}


#-----------------------------------------------------------
# �y�[�W�߂��胊���N���擾
#-----------------------------------------------------------
sub get_pagelinks_kindexview{

# �錾
my($type,$thread_num) = @_;
my($page,$mile,$accesskey4,$accesskey6,$newpage,$oldpage);
our($i_max,$menu1,$p,$line,$mine,%in,$i_max,$pastfile);

	# �A�N�Z�X�L�[��ݒ肷��ꍇ
	if($type =~ /Round1/){
		$accesskey4 = qq( accesskey="4");
		$accesskey6 = qq( accesskey="6");
	}

	# �y�[�W�߂��胊���N�i���j
	$newpage = $in{'p'} - $menu1;
	if($in{'p'} < $menu1){ $line .= qq(�C�V\n); }
	else{ $line .= qq(<a href="km${newpage}.html"$accesskey4>�C�V</a>\n); }

# �y�[�W�߂��胊���N
$page = $thread_num / $menu1;
$mile = 1;

	# �J��Ԃ�����
	while ($mile < $page + 1){
		$mine = ($mile - 1) * $menu1;
			if($p == $mine) { $line .= qq($mile\n); }
			else{ $line .= qq(<a href="km$mine.html">$mile</a>\n); }
		$mile++;
	}

	# �y�[�W�߂��胊���N�i���j
	$oldpage = $in{'p'} + $menu1;
	if($in{'p'} + $menu1 >= $thread_num){ $line .= qq(�E��\n); }
	else{ $line .= qq(<a href="km${oldpage}.html"$accesskey6>�E��</a>\n); }

	if(-f $main::newpastfile){
		$line .= qq( <a href="past.html">��</a>);
	}

# ���`
$line = qq(<div style="font-size:small;">$line</div>);

# ���^�[��
return($line);


}

no strict;

#-----------------------------------------------------------
# �^�C�g����`
#-----------------------------------------------------------
sub set_title_kindexview{

# �y�[�W������
if($in{'p'} ne "" && ($in{'p'} =~ /([^0-9])/) ){ &error("�y�[�W���̎w�肪�ςł��B"); }

# �^�C�g����`
if($menu1){ $plus_idx = int(($in{'p'} + $menu1) / $menu1); }

	# �g�b�v
	if(!$in{'p'}) {
		$sub_title .= "$head_title";
		$divide_url = "http://$server_domain/_$moto/";
	} 

	# �Q�y�[�W�ڈȍ~
	else{
		$sub_title .= "$plus_idx�� | $head_title";
		$divide_url = "http://$server_domain/_$moto/m$in{'p'}.html";
	}

	# ���_�C���N�g�ŐU�蕪��
	#if($device_type eq "desktop" && $divide_url){ &divide($divide_url,"desktop"); }

}


1;
