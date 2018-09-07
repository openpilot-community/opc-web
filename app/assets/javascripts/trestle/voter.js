'use strict';

class Voter extends React.Component {
  constructor(props) {
    super(props);
    
    this.state = {
      data: props.data,
      loading: false,
      hovered: false,
      voteBaseUrl: `/vehicles/${props.data.vehicle.id}/vote.json`
    };
  }

  handleStart() {
    this.setState({
      loading: true
    })
  }

  handleComplete() {
    this.setState({
      loading: false
    })
  }

  handleSuccess(response) {
    // console.warn("SUCCESS!",response);
    this.setState({
      "data": response
    });
    this.setUserVote(this.state);
  }

  handleFailure(response) {
    // console.warn("FAILED!",response);
  }
  
  vote(direction) {
    $.ajax({
      url: this.state.voteBaseUrl,
      dataType: 'json',
      type: 'get',
      beforeSend: () => this.handleStart(),
      success: (response) => this.handleSuccess(response),
      failed: (response) => this.handleFailure(response),
      complete: () => this.handleComplete(),
      data: {
        vote: direction
      }
    });
  }
  getVoteCount() {
    let votes = 0;

    if (this.state.data && this.state.data.vehicle) {
      votes = this.state.data.vehicle.votes;
    }
    return e(
      'span',
      {
        className: "badge badge-vote-count"
      },
      votes
    )
  }
  getIcon(icon) {
    return e(
      'span',
      {
        className: "fa fa-" + icon
      }
    ) 
  }
  setUserVote() {
    const vehicleId = this.state.data.vehicle.id;
    const votes = this.state.data.user.vehicle_votes;
    const current_vote = votes.find((vote) => { 
      return vote.id === vehicleId;
    });
    this.setState({
      "data.current_vote": current_vote 
    });
  }
  getVoteButton(direction) {
    let link_url;

    // if (!this.state.data.id || this.state.data.state === 0) {
    //   return;
    // }
    
    return e(
      'button',
      {
        className: "vote-" + direction,
        key: 'vote-direction-' + direction,
        disabled: this.state.loading,
        onClick: () => {
          this.vote(direction);
        }, 
      },
      this.getIcon('arrow-'+ direction)
    )
  }
  getClasses() {
    let classes = [];
    classes.push('voter');
    if (this.state.loading) {
      classes.push('loading');
    }
    if (this.state.data.current_vote && this.state.data.current_vote.vote) {
      classes.push("voted");
      classes.push('voted-' + this.state.data.current_vote.vote);
    }
    return classes.join(' ');
  }
  render() {
    const { data, loading } = this.state;
    let icon;
    let renders = [];

    if (loading) {
      renders.push(this.getIcon('spinner fa-spin'));
    }

    renders.push(this.getVoteButton('up'));
    renders.push(this.getVoteCount());
    renders.push(this.getVoteButton('down'));

    return e(
      'div',
      {
        className: this.getClasses()
      },
      renders
    )
  }
}

$(Trestle).on("init",function() {
  document.querySelectorAll('.vote-action').forEach(domContainer => {
    // Read the comment ID from a data-* attribute.
    const defaultState = JSON.parse(domContainer.dataset.defaultState);
    ReactDOM.render(
      e(Voter, {
        data: defaultState || {
          "vehicle": null,
          "user": null
        }
      }),
      domContainer
    );
  });
});