
class Person
{
private:
    /* data */
   
public:
    Person(/* args */);
    ~Person();
    
protected:
    int bodyCount; int age;int add();
};
int Person::add(){
    return age + age;
}
Person::Person(/* args */)
{
}

Person::~Person()
{
}

class Nigga: protected Person
{
private:
    /* data */
public:
    Nigga(/* args */);
    ~Nigga();
    int add();
};

Nigga::Nigga(/* args */)
{
}

Nigga::~Nigga()
{
}

int Nigga::add(){
    return age + bodyCount;
}

int main(int argc, char const *argv[])
{
    Nigga a;

    a.add();
    return 0;
}
