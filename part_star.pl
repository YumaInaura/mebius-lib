
#-----------------------------------------------------------
# ���e��̃X�^�[ - strict
#-----------------------------------------------------------
sub posted_get_star{

# �錾
my($line,$title);

# ����
if(rand(100) < 1){
$title="�����r�����X�^�[�o���i�R�j�I�@��������������Ȃ��ɂ́A�����Ɗ�Ղ��N����ł��傤�B";
$line = qq(<img src="/pct/star3.GIF" alt="���r�����X�^�[">);
}

elsif(rand(10) < 1){
$title="�����r�����X�^�[�i�Q�j�o���I�@���Ȃ��̉^���͑�㏸�ł��B";
$line = qq(<img src="/pct/star2.GIF" alt="���r�����X�^�[">);
}

else{
$title="�����r�����X�^�[�o���I�@���Ȃ��ɍK�����K��܂��悤�ɁB";
$line = qq(<img src="/pct/star1.GIF" alt="���r�����X�^�[">);
}

return($line,$title);

}

1;
