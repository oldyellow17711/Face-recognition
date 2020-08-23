function [accuracy]=my_face_recognition( train_dir,test_dir,train_num,test_num,energy,~ )
%�ú���ʵ��������PCA������������ʶ��Ĺ���
%Input
%       train_dir�������ݼ���Ŀ¼
%       test_dir���������ݼ���Ŀ¼
%       train_num��ѡ��Ŀ����ݼ��ĸ���
%       test_num��Ҫ���Ե����ݼ��ĸ�����ҪС�ڿ����ݼ�����

if train_num<=test_num
    fprintf('�����ݼ�Ҫ���ڲ������ݼ���\n');
    return ;
end


%��Ϊ�ļ���С�̶��������ڴ��������þ��������Ϊ��ֵ
row=315;
column=236;
train_data=zeros(train_num,row*column);%Ԥ�������ݿ��Լ������ݶ�ȡ������������ǿ����ݵĸ�����������ͼƬ��ά��
train_files=dir(train_dir);%��ȡ��Ŀ¼�µ������ļ�����õ�ÿһ���ļ�����һ���ṹ�壬������Ҫ�������е�name���ԡ���һ���͵ڶ����ļ��ֱ��ʾ��ǰĿ¼�͸�Ŀ¼����Ҫ����
for i=1:train_num
    file_name=sprintf('%s\\%s',train_dir,train_files(i+2).name);%������Ҫ��˫б��
    img_data = imread(file_name);
    [m,n] = size(img_data);
    if m ~= row || n ~= column
        img_data = imresize(img_data,[row column]);
    end
    %[row column]=size(img_data);
    img_data=img_data(1:row*column);%����ȡ������ת��һ��������
    train_data(i,:)=img_data;%������������ӵ��⼯��
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%��ƽ������������ʶ���޹أ�ֻ��һ������
imgmean=mean(train_data);
size(imgmean);
mean_img=reshape(imgmean,row,column);
mean_img=uint8(mean_img);
imwrite(mean_img,'H:\1.bmp');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%{
if b==1
    for i=1:test_num
        train_data(i,:)=train_data(i,:)-imgmean;
    end
end
%}

%�������ɷݷ��������صĽ��Ϊ
%   COEFF����������
%   latent������ֵ�����ɴ�С��˳������
%�����ݵ�ά�ȴ������ݸ���ʱ��ͨ���ں���������Ӳ�����econ�����Լ��ټ���
%[COEFF,~,latent] = princomp(train_data,'econ');

[COEFF,~,latent] = pca(train_data);

%�����ά�ȣ�����ֵ������ʹͼ�񱣴����������95%
dimension_left=0;
cum_percent=cumsum(latent)/sum(latent);
for i=1:length(cum_percent)
    if cum_percent(i)>=energy
        dimension_left=i;
        break;
    end
end
%fprintf('dimension left is %d\n',dimension_left);


%�������ݼ����н�ά
train_data_reduced=train_data*COEFF(:,1:dimension_left);

%��ȡ�������ݼ�
test_data=zeros(train_num,row*column);%Ԥ�������ݿ��Լ������ݶ�ȡ
test_files=dir(test_dir);%��ȡ��Ŀ¼�µ������ļ�����õ�ÿһ���ļ�����һ���ṹ�壬������Ҫ�������е�name���ԡ���һ���͵ڶ����ļ��ֱ��ʾ��ǰĿ¼�͸�Ŀ¼����Ҫ����
for i=1:test_num
    file_name=sprintf('%s\\%s',test_dir,test_files(i+2).name);%������Ҫ��˫б��
    
    img_data = imread(file_name);
    [m,n] = size(img_data);
    if m ~= row || n ~= column
        img_data = imresize(img_data,[row column]);
    end
    img_data=img_data(1:row*column);%����ȡ������ת��һ��������
    test_data(i,:)=img_data;%������������ӵ��⼯��
end

%{
if b==1
    for i=1:test_num
        test_data(i,:)=test_data(i,:)-imgmean;
    end
end
%}

%���������ݼ����н�ά
test_data_reduced=test_data*COEFF(:,1:dimension_left);

accuracy=0;
for i=1:test_num
    %ͨ�������������׷����ķ�������ŷʽ����
    min=norm(test_data_reduced(i,:)-train_data_reduced(1,:));
    position=1;
    for j=2:train_num
        distance=norm(test_data_reduced(i,:)-train_data_reduced(j,:));
        if min>distance
            min=distance;
            position=j;
        end
    end
    %fprintf('test_file:%s,train_file;%s\n',test_files(i+2).name,train_files(position+2).name);
    if same_person(test_files(i+2).name,train_files(position+2).name)==1
        accuracy=accuracy+1;
    else
        %fprintf('test_file:%s,train_file;%s\n',test_files(i+2).name,train_files(position+2).name);
    end
end
accuracy=accuracy/test_num;
fprintf('Accuracy is %f,energy %f,dimension left %d\n',accuracy,energy,dimension_left);

%�����Ƚ������ַ�����ǰ��λ�Ƿ���ͬ
    function result=same_person(s1,s2)
        result=strncmp(s1,s2,100);
    end
end

