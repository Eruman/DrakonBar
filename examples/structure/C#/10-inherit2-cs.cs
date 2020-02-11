// Autogenerated with DRAKON Editor 1.25
using System;
using System.Linq;
using System.Collections.Generic;
using System.Collections.ObjectModel;

class Bar {
	public delegate void AnyCode();
    public interface IBaseRecord
    {
        int Id { get; }
    }
    private interface IDelRecord
    {
        void PreDeleteOuter(System.Collections.Generic.HashSet<IDelRecord> deletionList, bool master);
        void EnsureCanDelete(System.Collections.Generic.HashSet<IDelRecord> deletionList);
        void DoDelete(Bar db, System.Collections.Generic.HashSet<IDelRecord> deletionList);
    }
    public interface IManager : IHuman {
        Int64 Bonus { get; set; }
    }
    public interface IItem : IBaseRecord {
        decimal Price { get; set; }
        IHuman Owner { get; }
    }
    public interface ICreature : IBaseRecord {
        int Dna { get; }
    }
    public interface IEmployee : IHuman {
        double Salary { get; set; }
    }
    public interface IHuman : ICreature {
        string Name { get; }
        ReadOnlyCollection<IItem> Items { get; }
    }
    public interface ISnack : IItem {
        string Taste { get; set; }
    }
    public interface ITool : IItem {
        string Usage { get; set; }
    }
    private readonly Dictionary<int, Manager> _manager_pk = new Dictionary<int, Manager>();
    private int _next_item = 1;
    private readonly Dictionary<int, Item> _item_pk = new Dictionary<int, Item>();
    private int _next_creature = 1;
    private readonly Dictionary<int, Creature> _creature_pk = new Dictionary<int, Creature>();
    private readonly Dictionary<int, Employee> _employee_pk = new Dictionary<int, Employee>();
    private readonly Dictionary<int, Human> _human_pk = new Dictionary<int, Human>();
    private readonly Dictionary<int, Snack> _snack_pk = new Dictionary<int, Snack>();
    private readonly Dictionary<int, Tool> _tool_pk = new Dictionary<int, Tool>();
    private class Creature_Dna_Comparer : IEqualityComparer<Creature> {
        public bool Equals(Creature x, Creature y) {
            if (x._dna != y._dna) return false;
            return true;
        }
        public int GetHashCode(Creature obj) {
            int code = obj._dna.GetHashCode();;
            return code;
        }
    }
    private readonly Dictionary<Creature, Creature> _creature_Dna = new Dictionary<Creature, Creature>(new Creature_Dna_Comparer());
    private class Human_Name_Comparer : IEqualityComparer<Human> {
        public bool Equals(Human x, Human y) {
            if (!Object.Equals(x._name, y._name)) return false;
            return true;
        }
        public int GetHashCode(Human obj) {
            int code = ((obj._name == null) ? 0 : obj._name.GetHashCode());
            return code;
        }
    }
    private readonly Dictionary<Human, Human> _human_Name = new Dictionary<Human, Human>(new Human_Name_Comparer());
    private class Manager : Human, IManager, IDelRecord {
        public Manager(int id) : base(id) {
        }
        public Int64 _bonus;
        public Int64 Bonus {
            get { return _bonus; }
            set { _bonus = value; }
        }
        public override void EnsureCanDelete(System.Collections.Generic.HashSet<IDelRecord> deletionList) {
        }
        public override void DoDelete(Bar db, System.Collections.Generic.HashSet<IDelRecord> deletionList) {
            db._human_Name.Remove(this);
            db._creature_Dna.Remove(this);
            db._manager_pk.Remove(_id);
            db._human_pk.Remove(_id);
            db._creature_pk.Remove(_id);
        }
        public override void PreDeleteOuter(System.Collections.Generic.HashSet<IDelRecord> deletionList, bool master) {
            if (deletionList.Contains(this)) {
                return;
            } else {
                deletionList.Add(this);
            }
            PreDeleteInner(deletionList);
        }
        public override void PreDeleteInner(System.Collections.Generic.HashSet<IDelRecord> deletionList) {
            base.PreDeleteInner(deletionList);
        }
    }
    private class Item : IItem, IDelRecord {
        public readonly int _id;
        public int Id { get { return _id; } }
        public Item(int id) {
            _id = id;
        }
        public decimal _price;
        public decimal Price {
            get { return _price; }
            set { _price = value; }
        }
        public Human _owner;
        public IHuman Owner {
            get { return _owner; }
        }
        public virtual void EnsureCanDelete(System.Collections.Generic.HashSet<IDelRecord> deletionList) {
        }
        public virtual void DoDelete(Bar db, System.Collections.Generic.HashSet<IDelRecord> deletionList) {
            if (_owner != null ) {
                if ( !deletionList.Contains(_owner)) {
                    _owner._items.Remove(this);
                }
            }
            db._item_pk.Remove(_id);
        }
        public virtual void PreDeleteOuter(System.Collections.Generic.HashSet<IDelRecord> deletionList, bool master) {
            if (deletionList.Contains(this)) {
                return;
            } else {
                deletionList.Add(this);
            }
            PreDeleteInner(deletionList);
        }
        public virtual void PreDeleteInner(System.Collections.Generic.HashSet<IDelRecord> deletionList) {
        }
    }
    private class Creature : ICreature, IDelRecord {
        public readonly int _id;
        public int Id { get { return _id; } }
        public Creature(int id) {
            _id = id;
        }
        public int _dna;
        public int Dna {
            get { return _dna; }
        }
        public virtual void EnsureCanDelete(System.Collections.Generic.HashSet<IDelRecord> deletionList) {
        }
        public virtual void DoDelete(Bar db, System.Collections.Generic.HashSet<IDelRecord> deletionList) {
            db._creature_Dna.Remove(this);
            db._creature_pk.Remove(_id);
        }
        public virtual void PreDeleteOuter(System.Collections.Generic.HashSet<IDelRecord> deletionList, bool master) {
            if (deletionList.Contains(this)) {
                return;
            } else {
                deletionList.Add(this);
            }
            PreDeleteInner(deletionList);
        }
        public virtual void PreDeleteInner(System.Collections.Generic.HashSet<IDelRecord> deletionList) {
        }
    }
    private readonly Creature _creature_Key = new Creature(0);
    private class Employee : Human, IEmployee, IDelRecord {
        public Employee(int id) : base(id) {
        }
        public double _salary;
        public double Salary {
            get { return _salary; }
            set { _salary = value; }
        }
        public override void EnsureCanDelete(System.Collections.Generic.HashSet<IDelRecord> deletionList) {
        }
        public override void DoDelete(Bar db, System.Collections.Generic.HashSet<IDelRecord> deletionList) {
            db._human_Name.Remove(this);
            db._creature_Dna.Remove(this);
            db._employee_pk.Remove(_id);
            db._human_pk.Remove(_id);
            db._creature_pk.Remove(_id);
        }
        public override void PreDeleteOuter(System.Collections.Generic.HashSet<IDelRecord> deletionList, bool master) {
            if (deletionList.Contains(this)) {
                return;
            } else {
                deletionList.Add(this);
            }
            PreDeleteInner(deletionList);
        }
        public override void PreDeleteInner(System.Collections.Generic.HashSet<IDelRecord> deletionList) {
            base.PreDeleteInner(deletionList);
        }
    }
    private class Human : Creature, IHuman, IDelRecord {
        public Human(int id) : base(id) {
            _items_Wrapper = _items.AsReadOnly();
        }
        public string _name;
        public string Name {
            get { return _name; }
        }
        public ReadOnlyCollection<IItem> _items_Wrapper;
        public readonly List<IItem> _items = new List<IItem>();
        public ReadOnlyCollection<IItem> Items {
            get { return _items_Wrapper; }
        }
        public override void EnsureCanDelete(System.Collections.Generic.HashSet<IDelRecord> deletionList) {
        }
        public override void DoDelete(Bar db, System.Collections.Generic.HashSet<IDelRecord> deletionList) {
            db._human_Name.Remove(this);
            db._creature_Dna.Remove(this);
            db._human_pk.Remove(_id);
            db._creature_pk.Remove(_id);
        }
        public override void PreDeleteOuter(System.Collections.Generic.HashSet<IDelRecord> deletionList, bool master) {
            if (deletionList.Contains(this)) {
                return;
            } else {
                deletionList.Add(this);
            }
            PreDeleteInner(deletionList);
        }
        public override void PreDeleteInner(System.Collections.Generic.HashSet<IDelRecord> deletionList) {
            foreach (Item _that_ in _items) {
                _that_.PreDeleteOuter(deletionList, false);
            }
            base.PreDeleteInner(deletionList);
        }
    }
    private readonly Human _human_Key = new Human(0);
    private class Snack : Item, ISnack, IDelRecord {
        public Snack(int id) : base(id) {
        }
        public string _taste;
        public string Taste {
            get { return _taste; }
            set { _taste = value; }
        }
        public override void EnsureCanDelete(System.Collections.Generic.HashSet<IDelRecord> deletionList) {
        }
        public override void DoDelete(Bar db, System.Collections.Generic.HashSet<IDelRecord> deletionList) {
            if (_owner != null ) {
                if ( !deletionList.Contains(_owner)) {
                    _owner._items.Remove(this);
                }
            }
            db._snack_pk.Remove(_id);
            db._item_pk.Remove(_id);
        }
        public override void PreDeleteOuter(System.Collections.Generic.HashSet<IDelRecord> deletionList, bool master) {
            if (deletionList.Contains(this)) {
                return;
            } else {
                deletionList.Add(this);
            }
            PreDeleteInner(deletionList);
        }
        public override void PreDeleteInner(System.Collections.Generic.HashSet<IDelRecord> deletionList) {
            base.PreDeleteInner(deletionList);
        }
    }
    private class Tool : Item, ITool, IDelRecord {
        public Tool(int id) : base(id) {
        }
        public string _usage;
        public string Usage {
            get { return _usage; }
            set { _usage = value; }
        }
        public override void EnsureCanDelete(System.Collections.Generic.HashSet<IDelRecord> deletionList) {
        }
        public override void DoDelete(Bar db, System.Collections.Generic.HashSet<IDelRecord> deletionList) {
            if (_owner != null ) {
                if ( !deletionList.Contains(_owner)) {
                    _owner._items.Remove(this);
                }
            }
            db._tool_pk.Remove(_id);
            db._item_pk.Remove(_id);
        }
        public override void PreDeleteOuter(System.Collections.Generic.HashSet<IDelRecord> deletionList, bool master) {
            if (deletionList.Contains(this)) {
                return;
            } else {
                deletionList.Add(this);
            }
            PreDeleteInner(deletionList);
        }
        public override void PreDeleteInner(System.Collections.Generic.HashSet<IDelRecord> deletionList) {
            base.PreDeleteInner(deletionList);
        }
    }
    public IManager InsertManager(int id, int dna, string name) {
        if ( id == 0 ) {
            id = _next_creature;
        } else {
            if (_creature_pk.ContainsKey(id)) {
                string className = _creature_pk[id].GetType().Name;
                throw new ArgumentException(String.Format(
                    "'{0}' with id '{1}' already exists.",
                    className, id));
            }
        }
        if ( id >= _next_creature ) {
            _next_creature = id + 1;
        }
        var _record_ = new Manager(id);
        _record_._dna = dna;
        _record_._name = name;
        _creature_pk[id] = _record_;
        _human_pk[id] = _record_;
        _manager_pk[id] = _record_;
        _creature_Dna[_record_] = _record_;
        _human_Name[_record_] = _record_;
        return _record_;
    }
    public IManager GetManager(int id) {
        Manager _record_;
        if (!_manager_pk.TryGetValue(id, out _record_)) {
            return null;
        }
        return _record_;
    }
    public int ManagerCount() {
        return _manager_pk.Count;
    }
    public IEnumerable<IManager> EachManager() {
        foreach (KeyValuePair<int, Manager> record in _manager_pk) {
            yield return record.Value;
        }
    }
    public void DeleteManager(IManager record) {
        if (record == null) return;
        Manager _record_;
        var deletionList = new System.Collections.Generic.HashSet<IDelRecord>();
        if ( !_manager_pk.TryGetValue(record.Id, out _record_)) {
            throw new ArgumentException(String.Format(
                "'Manager' with id '{0}' does not exist.",
                record.Id));
        }
        _record_.PreDeleteOuter(deletionList, false);
        foreach (IDelRecord item in deletionList) {
            item.EnsureCanDelete(deletionList);
        }
        foreach (IDelRecord item in deletionList) {
            item.DoDelete(this, deletionList);
        }
    }
    public IItem InsertItem(int id) {
        if ( id == 0 ) {
            id = _next_item;
        } else {
            if (_item_pk.ContainsKey(id)) {
                string className = _item_pk[id].GetType().Name;
                throw new ArgumentException(String.Format(
                    "'{0}' with id '{1}' already exists.",
                    className, id));
            }
        }
        if ( id >= _next_item ) {
            _next_item = id + 1;
        }
        var _record_ = new Item(id);
        _item_pk[id] = _record_;
        return _record_;
    }
    public IItem GetItem(int id) {
        Item _record_;
        if (!_item_pk.TryGetValue(id, out _record_)) {
            return null;
        }
        return _record_;
    }
    public int ItemCount() {
        return _item_pk.Count;
    }
    public IEnumerable<IItem> EachItem() {
        foreach (KeyValuePair<int, Item> record in _item_pk) {
            yield return record.Value;
        }
    }
    public void DeleteItem(IItem record) {
        if (record == null) return;
        Item _record_;
        var deletionList = new System.Collections.Generic.HashSet<IDelRecord>();
        if ( !_item_pk.TryGetValue(record.Id, out _record_)) {
            throw new ArgumentException(String.Format(
                "'Item' with id '{0}' does not exist.",
                record.Id));
        }
        _record_.PreDeleteOuter(deletionList, false);
        foreach (IDelRecord item in deletionList) {
            item.EnsureCanDelete(deletionList);
        }
        foreach (IDelRecord item in deletionList) {
            item.DoDelete(this, deletionList);
        }
    }
    public void SetItemOwner(IItem record, IHuman newValue) {
        Item _record_;
        if ( !_item_pk.TryGetValue(record.Id, out _record_)) {
            throw new ArgumentException(String.Format(
                "'Item' with id '{0}' does not exist.",
                record.Id));
        }
        if (Object.Equals(_record_._owner, newValue)) {
            return;
        }
        Human _that_;
        if (newValue == null ) {
            _that_ = null;
        } else if (!_human_pk.TryGetValue(newValue.Id, out _that_)) {
            throw new ArgumentException(String.Format(
                "'Human' with id '{0}' does not exist.",
                newValue.Id));
        }
        if (_record_._owner != null ) {
            _record_._owner._items.Remove(_record_);
        }
        _record_._owner = _that_;
        if (_record_._owner != null ) {
            _record_._owner._items.Add(_record_);
        }
    }
    public ICreature InsertCreature(int id, int dna) {
        if ( id == 0 ) {
            id = _next_creature;
        } else {
            if (_creature_pk.ContainsKey(id)) {
                string className = _creature_pk[id].GetType().Name;
                throw new ArgumentException(String.Format(
                    "'{0}' with id '{1}' already exists.",
                    className, id));
            }
        }
        if ( id >= _next_creature ) {
            _next_creature = id + 1;
        }
        _creature_Key._dna = dna;
        if ( _creature_Dna.ContainsKey(_creature_Key)) {
            throw new ArgumentException(
              "Fields 'Dna' are not unique for 'Creature'.");
        }
        var _record_ = new Creature(id);
        _record_._dna = dna;
        _creature_pk[id] = _record_;
        _creature_Dna[_record_] = _record_;
        return _record_;
    }
    public ICreature GetCreature(int id) {
        Creature _record_;
        if (!_creature_pk.TryGetValue(id, out _record_)) {
            return null;
        }
        return _record_;
    }
    public int CreatureCount() {
        return _creature_pk.Count;
    }
    public IEnumerable<ICreature> EachCreature() {
        foreach (KeyValuePair<int, Creature> record in _creature_pk) {
            yield return record.Value;
        }
    }
    public void DeleteCreature(ICreature record) {
        if (record == null) return;
        Creature _record_;
        var deletionList = new System.Collections.Generic.HashSet<IDelRecord>();
        if ( !_creature_pk.TryGetValue(record.Id, out _record_)) {
            throw new ArgumentException(String.Format(
                "'Creature' with id '{0}' does not exist.",
                record.Id));
        }
        _record_.PreDeleteOuter(deletionList, false);
        foreach (IDelRecord item in deletionList) {
            item.EnsureCanDelete(deletionList);
        }
        foreach (IDelRecord item in deletionList) {
            item.DoDelete(this, deletionList);
        }
    }
    public ICreature FindCreatureByDna(int dna) {
        Creature _record_;
        _creature_Key._dna = dna;
        if (_creature_Dna.TryGetValue(_creature_Key, out _record_)) {
            return _record_;
        } else {
            return null;
        }
    }
    public void SetCreatureDna(ICreature record, int newValue) {
        Creature _record_;
        if ( !_creature_pk.TryGetValue(record.Id, out _record_)) {
            throw new ArgumentException(String.Format(
                "'Creature' with id '{0}' does not exist.",
                record.Id));
        }
        if (_record_._dna == newValue) {
            return;
        }
        _creature_Key._dna = newValue;
        if ( _creature_Dna.ContainsKey(_creature_Key)) {
            throw new ArgumentException(
              "Fields 'Dna' are not unique for 'Creature'.");
        }
        _creature_Dna.Remove(_record_);
        _record_._dna = newValue;
        _creature_Dna[_record_] = _record_;
    }
    public IEmployee InsertEmployee(int id, int dna, string name) {
        if ( id == 0 ) {
            id = _next_creature;
        } else {
            if (_creature_pk.ContainsKey(id)) {
                string className = _creature_pk[id].GetType().Name;
                throw new ArgumentException(String.Format(
                    "'{0}' with id '{1}' already exists.",
                    className, id));
            }
        }
        if ( id >= _next_creature ) {
            _next_creature = id + 1;
        }
        var _record_ = new Employee(id);
        _record_._dna = dna;
        _record_._name = name;
        _creature_pk[id] = _record_;
        _human_pk[id] = _record_;
        _employee_pk[id] = _record_;
        _creature_Dna[_record_] = _record_;
        _human_Name[_record_] = _record_;
        return _record_;
    }
    public IEmployee GetEmployee(int id) {
        Employee _record_;
        if (!_employee_pk.TryGetValue(id, out _record_)) {
            return null;
        }
        return _record_;
    }
    public int EmployeeCount() {
        return _employee_pk.Count;
    }
    public IEnumerable<IEmployee> EachEmployee() {
        foreach (KeyValuePair<int, Employee> record in _employee_pk) {
            yield return record.Value;
        }
    }
    public void DeleteEmployee(IEmployee record) {
        if (record == null) return;
        Employee _record_;
        var deletionList = new System.Collections.Generic.HashSet<IDelRecord>();
        if ( !_employee_pk.TryGetValue(record.Id, out _record_)) {
            throw new ArgumentException(String.Format(
                "'Employee' with id '{0}' does not exist.",
                record.Id));
        }
        _record_.PreDeleteOuter(deletionList, false);
        foreach (IDelRecord item in deletionList) {
            item.EnsureCanDelete(deletionList);
        }
        foreach (IDelRecord item in deletionList) {
            item.DoDelete(this, deletionList);
        }
    }
    public IHuman InsertHuman(int id, int dna, string name) {
        if ( id == 0 ) {
            id = _next_creature;
        } else {
            if (_creature_pk.ContainsKey(id)) {
                string className = _creature_pk[id].GetType().Name;
                throw new ArgumentException(String.Format(
                    "'{0}' with id '{1}' already exists.",
                    className, id));
            }
        }
        if ( id >= _next_creature ) {
            _next_creature = id + 1;
        }
        _human_Key._name = name;
        if ( _human_Name.ContainsKey(_human_Key)) {
            throw new ArgumentException(
              "Fields 'Name' are not unique for 'Human'.");
        }
        _human_Key._name = name;
        if ( _human_Name.ContainsKey(_human_Key)) {
            throw new ArgumentException(
              "Fields 'Name' are not unique for 'Human'.");
        }
        var _record_ = new Human(id);
        _record_._dna = dna;
        _record_._name = name;
        _creature_pk[id] = _record_;
        _human_pk[id] = _record_;
        _creature_Dna[_record_] = _record_;
        _human_Name[_record_] = _record_;
        return _record_;
    }
    public IHuman GetHuman(int id) {
        Human _record_;
        if (!_human_pk.TryGetValue(id, out _record_)) {
            return null;
        }
        return _record_;
    }
    public int HumanCount() {
        return _human_pk.Count;
    }
    public IEnumerable<IHuman> EachHuman() {
        foreach (KeyValuePair<int, Human> record in _human_pk) {
            yield return record.Value;
        }
    }
    public void DeleteHuman(IHuman record) {
        if (record == null) return;
        Human _record_;
        var deletionList = new System.Collections.Generic.HashSet<IDelRecord>();
        if ( !_human_pk.TryGetValue(record.Id, out _record_)) {
            throw new ArgumentException(String.Format(
                "'Human' with id '{0}' does not exist.",
                record.Id));
        }
        _record_.PreDeleteOuter(deletionList, false);
        foreach (IDelRecord item in deletionList) {
            item.EnsureCanDelete(deletionList);
        }
        foreach (IDelRecord item in deletionList) {
            item.DoDelete(this, deletionList);
        }
    }
    public IHuman FindHumanByName(string name) {
        Human _record_;
        _human_Key._name = name;
        if (_human_Name.TryGetValue(_human_Key, out _record_)) {
            return _record_;
        } else {
            return null;
        }
    }
    public void SetHumanName(IHuman record, string newValue) {
        Human _record_;
        if ( !_human_pk.TryGetValue(record.Id, out _record_)) {
            throw new ArgumentException(String.Format(
                "'Human' with id '{0}' does not exist.",
                record.Id));
        }
        if (Object.Equals(_record_._name, newValue)) {
            return;
        }
        _human_Key._name = newValue;
        if ( _human_Name.ContainsKey(_human_Key)) {
            throw new ArgumentException(
              "Fields 'Name' are not unique for 'Human'.");
        }
        _human_Name.Remove(_record_);
        _record_._name = newValue;
        _human_Name[_record_] = _record_;
    }
    public ISnack InsertSnack(int id) {
        if ( id == 0 ) {
            id = _next_item;
        } else {
            if (_item_pk.ContainsKey(id)) {
                string className = _item_pk[id].GetType().Name;
                throw new ArgumentException(String.Format(
                    "'{0}' with id '{1}' already exists.",
                    className, id));
            }
        }
        if ( id >= _next_item ) {
            _next_item = id + 1;
        }
        var _record_ = new Snack(id);
        _item_pk[id] = _record_;
        _snack_pk[id] = _record_;
        return _record_;
    }
    public ISnack GetSnack(int id) {
        Snack _record_;
        if (!_snack_pk.TryGetValue(id, out _record_)) {
            return null;
        }
        return _record_;
    }
    public int SnackCount() {
        return _snack_pk.Count;
    }
    public IEnumerable<ISnack> EachSnack() {
        foreach (KeyValuePair<int, Snack> record in _snack_pk) {
            yield return record.Value;
        }
    }
    public void DeleteSnack(ISnack record) {
        if (record == null) return;
        Snack _record_;
        var deletionList = new System.Collections.Generic.HashSet<IDelRecord>();
        if ( !_snack_pk.TryGetValue(record.Id, out _record_)) {
            throw new ArgumentException(String.Format(
                "'Snack' with id '{0}' does not exist.",
                record.Id));
        }
        _record_.PreDeleteOuter(deletionList, false);
        foreach (IDelRecord item in deletionList) {
            item.EnsureCanDelete(deletionList);
        }
        foreach (IDelRecord item in deletionList) {
            item.DoDelete(this, deletionList);
        }
    }
    public ITool InsertTool(int id) {
        if ( id == 0 ) {
            id = _next_item;
        } else {
            if (_item_pk.ContainsKey(id)) {
                string className = _item_pk[id].GetType().Name;
                throw new ArgumentException(String.Format(
                    "'{0}' with id '{1}' already exists.",
                    className, id));
            }
        }
        if ( id >= _next_item ) {
            _next_item = id + 1;
        }
        var _record_ = new Tool(id);
        _item_pk[id] = _record_;
        _tool_pk[id] = _record_;
        return _record_;
    }
    public ITool GetTool(int id) {
        Tool _record_;
        if (!_tool_pk.TryGetValue(id, out _record_)) {
            return null;
        }
        return _record_;
    }
    public int ToolCount() {
        return _tool_pk.Count;
    }
    public IEnumerable<ITool> EachTool() {
        foreach (KeyValuePair<int, Tool> record in _tool_pk) {
            yield return record.Value;
        }
    }
    public void DeleteTool(ITool record) {
        if (record == null) return;
        Tool _record_;
        var deletionList = new System.Collections.Generic.HashSet<IDelRecord>();
        if ( !_tool_pk.TryGetValue(record.Id, out _record_)) {
            throw new ArgumentException(String.Format(
                "'Tool' with id '{0}' does not exist.",
                record.Id));
        }
        _record_.PreDeleteOuter(deletionList, false);
        foreach (IDelRecord item in deletionList) {
            item.EnsureCanDelete(deletionList);
        }
        foreach (IDelRecord item in deletionList) {
            item.DoDelete(this, deletionList);
        }
    }

    public ISnack CreateSnack(IHuman owner, decimal price, string taste) {
        // item 391
        ISnack snack = InsertSnack(0);
        snack.Taste = taste;
        snack.Price = price;
        SetItemOwner(snack, owner);
        // item 286
        return snack;
    }

    public ITool CreateTool(IHuman owner, decimal price, string usage) {
        // item 400
        ITool tool = InsertTool(0);
        tool.Usage = usage;
        tool.Price = price;
        SetItemOwner(tool, owner);
        // item 293
        return tool;
    }

    public static void Equal(object expected, object actual) {
        // item 346
        //PutObj(expected);
        //PutObj(actual);
        //Put("\n");
        // item 343
        if (Object.Equals(expected, actual)) {
            
        } else {
            // item 325
            if (expected is System.Collections.IEnumerable) {
                // item 331
                if (actual is System.Collections.IEnumerable) {
                    // item 334
                    var expectedEn = (System.Collections.IEnumerable)expected;
                    var actualEn = (System.Collections.IEnumerable)actual;
                    // item 345
                    List<object> exList = expectedEn.Cast<object>().ToList();
                    List<object> acList = actualEn.Cast<object>().ToList();
                    // item 335
                    if (exList.Count == acList.Count) {
                        // item 3380001
                        int i = 0;
                        while (true) {
                            // item 3380002
                            if (i < exList.Count) {
                                
                            } else {
                                break;
                            }
                            // item 340
                            Equal(exList[i], acList[i]);
                            // item 3380003
                            i++;
                        }
                    } else {
                        // item 347
                        string message = 
                        String.Format("Collections have different sizes: expected={0}, actual={1}", 
                        	exList.Count, acList.Count);
                        // item 337
                        throw new Exception(message);
                    }
                } else {
                    // item 333
                    throw new Exception("Both should be IEnumerable");
                }
            } else {
                // item 328
                if (actual is System.Collections.IEnumerable) {
                    // item 329
                    throw new Exception("Both should be IEnumerable");
                } else {
                    // item 341
                    throw new Exception("Objects are not equal.");
                }
            }
        }
    }

    public static void ExpectException(AnyCode code) {
        // item 362
        bool caught = false;
        try {
            code();
        }
        catch {
            caught = true;
        }
        // item 363
        if (caught) {
            
        } else {
            // item 366
            throw new Exception("Exception expected but not thrown.");
        }
    }

    public static void Main() {
        // item 403
        Bar db = new Bar();
        // item 257
        IHuman gandalf = db.InsertManager(0, 10101, "Gandalf");
        IHuman bilbo   = db.InsertEmployee(0, 10102, "Bilbo");
        IHuman fedor   = db.InsertEmployee(0, 10103, "Fedor");
        // item 268
        IItem hammer = db.CreateTool(gandalf, 100, "nail");
        IItem loaf   = db.CreateSnack(gandalf, 110, "fresh");
        IItem saw    = db.CreateTool(fedor, 200, "saw");
        IItem driver = db.CreateTool(fedor, 120, "drive screws");
        IItem spade  = db.CreateTool(fedor, 150, "dig");
        // item 294
        Equal(new IItem[] {hammer, loaf},
         gandalf.Items);
        Equal(new IItem[] {},
         bilbo.Items);
        Equal(new IItem[] {saw, driver, spade},
         fedor.Items);
        // item 318
        Equal(5, db.ItemCount());
        Equal(4, db.ToolCount());
        Equal(1, db.SnackCount());
        // item 303
        Equal(hammer, db.GetItem(hammer.Id));
        Equal(hammer, db.GetTool(hammer.Id));
        Equal(null, db.GetSnack(hammer.Id));
        Equal(true, hammer is ITool);
        // item 304
        Equal(saw, db.GetItem(saw.Id));
        Equal(saw, db.GetTool(saw.Id));
        Equal(null, db.GetSnack(saw.Id));
        Equal(true, saw is ITool);
        // item 305
        Equal(driver, db.GetItem(driver.Id));
        Equal(driver, db.GetTool(driver.Id));
        Equal(null, db.GetSnack(driver.Id));
        Equal(true, driver is ITool);
        // item 306
        Equal(spade, db.GetItem(spade.Id));
        Equal(spade, db.GetTool(spade.Id));
        Equal(null, db.GetSnack(spade.Id));
        Equal(true, spade is ITool);
        // item 307
        Equal(loaf, db.GetItem(loaf.Id));
        Equal(null, db.GetTool(loaf.Id));
        Equal(loaf, db.GetSnack(loaf.Id));
        Equal(true, loaf is ISnack);
        // item 308
        db.DeleteItem(hammer);
        // item 309
        Equal(new IItem[] {loaf},
         gandalf.Items);
        // item 295
        Equal(null, db.GetItem(hammer.Id));
        Equal(null, db.GetTool(hammer.Id));
        Equal(null, db.GetSnack(hammer.Id));
        // item 310
        db.DeleteTool((ITool)spade);
        // item 311
        Equal(null, db.GetItem(spade.Id));
        Equal(null, db.GetTool(spade.Id));
        Equal(null, db.GetSnack(spade.Id));
        // item 312
        Equal(new IItem[] {saw, driver},
         fedor.Items);
        // item 313
        db.DeleteHuman(fedor);
        // item 314
        Equal(null, db.GetItem(saw.Id));
        Equal(null, db.GetTool(saw.Id));
        Equal(null, db.GetSnack(saw.Id));
        // item 315
        Equal(null, db.GetItem(driver.Id));
        Equal(null, db.GetTool(driver.Id));
        Equal(null, db.GetSnack(driver.Id));
        // item 319
        Equal(loaf, db.GetItem(loaf.Id));
        Equal(null, db.GetTool(loaf.Id));
        Equal(loaf, db.GetSnack(loaf.Id));
        Equal(true, loaf is ISnack);
        // item 317
        Equal(1, db.ItemCount());
        Equal(0, db.ToolCount());
        Equal(1, db.SnackCount());
    }

    public static void NotEqual(object left, object right) {
        // item 353
        if (Object.Equals(left, right)) {
            // item 356
            throw new Exception("Objects are equal.");
        } else {
            
        }
    }

    public static void Put(string format, params object[] args) {
        // item 372
        System.Console.WriteLine(format, args);
    }

    public static void PutObj(object obj) {
        // item 378
        IBaseRecord rec = obj as IBaseRecord;
        // item 380
        if (rec == null) {
            // item 383
            Put("{0}", obj);
        } else {
            // item 379
            Console.WriteLine("{0} {1}", rec.GetType().Name, rec.Id);
        }
    }

    private static List<IBaseRecord> Sort<T>(IEnumerable<T> input) {
        // item 387
        List<IBaseRecord> records = (
        	from it in input
        	select (IBaseRecord)it).ToList();
        // item 390
        return (from rec in records
        	orderby rec.Id
        	select rec).ToList();
    }
}

