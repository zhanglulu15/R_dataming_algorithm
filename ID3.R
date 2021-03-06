#计算给定数据集的熵
calShannon<-function(D)
{ #数据集最后一列必须是是类标号
  N<-dim(D)[1] #数据集的行数
  #类标号
  labelCount<- as.data.frame(table(D[,dim(D)[2]]))
  colnames(labelCount)<-c("label","Freq")
  #排除掉类标号数量为0的
  labelCount<-labelCount[labelCount[,2]>0,]
  labelCount[,2]<- -1*( (labelCount[,2]/N)*log2(labelCount[,2]/N) )
  #apply(labelCount,1,function(r) return(r[[2]]/N))
  shannon<-sum(labelCount[,2])
  return(shannon)
}

#按照给定属性和属性的取值 划分数据集 ，为计算子集Dj的熵准备数据
splitData<-function(D,attru,value)
{ #attru 选择的属性的顺序值  ,value 选择属性的值
  D<-D[D[,attru]==value,][,-attru]
  return(as.data.frame(D))
}

#选择最优的属性
chooseBestAttru<-function(D)
{ 
  N<-dim(D)[1] #数据集的行数
  if(N==0)
  {return(0)}else
  if(dim(D)[2]<=2)
  {return(1)
  }else{
  numAttru<-dim(D)[2]-1
  info_D<-calShannon(D) #  info(D)
  newEntropy=data.frame(attru=1:numAttru,entropy=0)
  BestAttru=0 
  for(i in 1:numAttru)
  {
    unique_Attru<-unique(D[,i])
    newEntropy<=0 #计算每个属性的熵
    for(v in unique_Attru )
    {
      subData<-splitData(D,i,v)
      prob=dim(subData)[1]/N
      newEntropy[i,2]<-newEntropy[i,2]+ prob * calShannon(subData)
    }
   } 
   
   bestInfoGain=data.frame(attru=newEntropy[,1],entropy=-1*(newEntropy[,2]-info_D))
   return(bestInfoGain[bestInfoGain[,2]==max(bestInfoGain[,2]),][1,1] )
}
}

#多数表决函数
#没有剩余属性进一步划分，使用多数表决
major_Lable<-function(class_list)
{
  class_count<-as.data.frame(table(class_list ))
  class_count<-class_count[order(class_count$Freq,decreasing=T),]
  return(as.vector(class_count[1,1]))
}  

attribute_list<-colnames(D)[1:(length(colnames(D))-1)]

#创建决策树 生成树的阶段
createTree_ID3<-function(D,attribute_list)
{ 
  D<-as.data.frame(D)
  class_list<-as.vector(D[,dim(D)[2]])  #最后一行的类别
  class_label<-unique(class_list) 
  #1:如果D中的数据都在同一个类中 返回N作为叶子节点
  if(length(class_label)==1)
  {
    return(class_label[1])
  }else 
    if(length(attribute_list)==0)
    {# 2:没有剩余属性进一步划分，使用多数表决。可以遍历完所有特征时返回出现次数最多的 
      return(major_Lable(class_list))
    }else
  {
  # 3：调用chooseBestAttru 选择最优的属性
  bestAttru=chooseBestAttru(D)
  bestAttru_name=attribute_list[bestAttru]
  #选择最优的属性 标记节点N
  myTree<- list()
  myTree[[bestAttru_name]] <- list()
  #g=g+vertices(bestAttru_name)
  #如果最优的属性N 是离散的且允许多路划分
  #删除分裂属性 #A-B
  sub_attribute_list=setdiff(attribute_list,bestAttru_name)
  unique_Value_BestAttru<-sort(as.character(unique(D[,bestAttru])))
  #对最优的属性N 的每个分支的分区产生子树
  for(v in unique_Value_BestAttru )
  { 
    sub_D<-splitData(D, bestAttru, v)
    if(dim(sub_D)[1]>0)
      { 
         myTree[[bestAttru_name]][[v]]<- createTree_ID3(sub_D,sub_attribute_list) 
      }   
  }    
  return(myTree)
  }
}


##创建决策树生成树的阶段
attribute_list<-colnames(D)[1:(length(colnames(D))-1)]
createTree_ID3(D,attribute_list)

