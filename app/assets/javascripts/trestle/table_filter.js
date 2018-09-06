'use strict';

class TableFilter extends React.Component {
  constructor(props) {
    super(props);
    // console.warn(props);
    this.state = {
      data: props.data,
      loading: false,
      hovered: false
    };
  }
  handleFilter(ev,val) {
    $(".trestle-table tbody tr").hide();
    $(`.trestle-table tbody tr td:contains('${ev.target.value}')`).each(function(i,val) {
      var $this = $(this);
      var $parent = $this.parents('tr');
      $parent.show();
    })
  }
  render() {
    const { data, loading } = this.state;
    const handleFilter = this.handleFilter;
    const input = e(
      'input',
      {
        type: 'text',
        className: "form-control input-block search-filter",
        placeholder: "Type to filter capabilities...",
        onKeyUp: this.handleFilter,
        style: {
          marginBottom: '10px'
        }
      });
    return input;
  }
}

$(Trestle).on("init",function() {
  document.querySelectorAll('.table-filter').forEach(domContainer => {
    // Read the comment ID from a data-* attribute.
    // const defaultState = JSON.parse(domContainer.dataset.defaultState);
    ReactDOM.render(
      e(TableFilter),
      domContainer
    );
  });
});