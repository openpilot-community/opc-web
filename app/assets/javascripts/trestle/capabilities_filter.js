'use strict';

class CapabilitiesFilter extends React.Component {
  constructor(props) {
    super(props);
    // console.warn(props);
    this.state = {
      data: props.data,
      loading: false,
      hovered: false
    };
  }
  changeGroup(ev,val) {
    $(`#tab-capabilities .trestle-table tbody tr`).each(function(i,row) {
      var $this = $(this);
      if ($this.hasClass(val) || val === 'all') {
        $this.show();
      } else {
        $this.hide();
      }
    });
  }
  handleFilter(ev,val) {
    $("#tab-capabilities .trestle-table tbody tr").hide();
    $(`#tab-capabilities .trestle-table tbody tr td:contains('${ev.target.value}')`).each(function(i,val) {
      var $this = $(this);
      var $parent = $this.parents('tr');
      $parent.show();
    })
  }
  render() {
    const { data, loading } = this.state;
    const handleFilter = this.handleFilter;
    const changeGroup = this.changeGroup;
    let renders = [];
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
      }
    );
    const allGroups = e(
      'button',
      {
        type: 'button',
        className: "btn btn-default btn-list-filter",
        onClick: (ev) => {
          this.changeGroup(ev,'all');
        }
      },
      'All'
    );
    const usedOnly = e(
      'button',
      {
        type: 'button',
        className: "btn btn-default btn-list-filter",
        onClick: (ev) => {
          this.changeGroup(ev,'has-capability');
        }
      },
      'Used'
    );
    const commonOnly = e(
      'button',
      {
        type: 'button',
        className: "btn btn-default btn-list-filter",
        onClick: (ev) => {
          this.changeGroup(ev,'common');
        }
      },
      'Common'
    );

    const uncommonOnly = e(
      'button',
      {
        type: 'button',
        className: "btn btn-default btn-list-filter",
        onClick: (ev) => {
          this.changeGroup(ev,'uncommon');
        }
      },
      'Uncommon'
    );

    renders.push(input, allGroups, usedOnly,commonOnly,uncommonOnly)
    return renders;
  }
}

$(Trestle).on("init",function() {
  document.querySelectorAll('.table-filter').forEach(domContainer => {
    // Read the comment ID from a data-* attribute.
    // const defaultState = JSON.parse(domContainer.dataset.defaultState);
    ReactDOM.render(
      e(CapabilitiesFilter),
      domContainer
    );
  });
});