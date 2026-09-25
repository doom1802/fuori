/* Sample public events and a private invitation for the mobile concept. */
(() => {
  const extraEvents = {
    murazzi: {title:'Un salto ai Murazzi',place:'Murazzi del Po, Torino',date:'Mercoledì 23 settembre',short:'MER 23 SET',time:'22:00 – 00:30',total:18,friends:['Leo']},
    jazz: {title:'Jazz dopo cena',place:'Jazz Club Torino',date:'Giovedì 24 settembre',short:'GIO 24 SET',time:'22:30 – 00:30',total:31,friends:['Vale','Fra']}
  };
  const sample = [
    {type:'event',id:'aperitivo',date:'2026-09-23',time:'19:00'},
    {type:'event',id:'murazzi',date:'2026-09-23',time:'22:00'},
    {type:'event',id:'coguaro',date:'2026-09-24',time:'21:00'},
    {type:'event',id:'jazz',date:'2026-09-24',time:'22:30'},
    {type:'event',id:'concerto',date:'2026-09-25',time:'20:30'},
    {type:'event',id:'sabato',date:'2026-09-26',time:'18:30'},
    {type:'invite',id:'fra',date:'2026-09-26',time:'20:30'}
  ];
  const dayDates = {
    '2026-09-23':'Mercoledì 23 settembre',
    '2026-09-24':'Giovedì 24 settembre',
    '2026-09-25':'Venerdì 25 settembre',
    '2026-09-26':'Sabato 26 settembre',
    '2026-09-27':'Domenica 27 settembre'
  };
  function dayFor(date){
    if(date==='2026-09-23')return 'today';
    if(date==='2026-09-24')return 'tomorrow';
    if(date>='2026-09-25'&&date<='2026-09-27')return 'weekend';
    return null;
  }
  function itemsFor(day,state){
    const items=sample.filter(item=>!day||dayFor(item.date)===day).map(item=>({...item}));
    state.createdEvents.forEach((event,index)=>{
      if(!day||dayFor(event.date)===day)items.push({type:'created',id:index,date:event.date,time:event.time||'00:00'});
    });
    items.sort((a,b)=>(a.date+'T'+a.time).localeCompare(b.date+'T'+b.time));
    return items;
  }
  function details(item,opts){
    const {state,events,rsvps}=opts;
    if(item.type==='event'){
      const event=events[item.id];
      return {title:event.title,kind:'Evento pubblico',sub:event.place+' · '+event.friends.length+' amici · '+(event.total+(rsvps[item.id]?1:0))+' partecipanti',action:'event:'+item.id};
    }
    if(item.type==='invite'){
      return {title:'La serata è da Fra',kind:'Invito privato',sub:'Casa di Fra · '+(12+(state.privateResponses?.sample?.joined?1:0))+' partecipanti',action:'sample-invite'};
    }
    const event=state.createdEvents[item.id];
    return {title:event.title,kind:'Organizzi tu',sub:event.place+' · '+(event.visibility==='private'?'su invito':'pubblico'),action:'managed:'+item.id};
  }
  function row(item,opts){
    const info=details(item,opts),safe=opts.esc,arrow=opts.icon('chevron-right');
    return '<button class="plan-entry cursor-interaction" type="button" data-action="'+safe(info.action)+'" aria-label="'+safe(info.title+', '+item.time+', '+info.sub)+'">'+
      '<span class="plan-time">'+safe(item.time)+'<small>Torino</small></span>'+
      '<span class="plan-copy"><small class="plan-type">'+safe(info.kind)+'</small><strong>'+safe(info.title)+'</strong><small>'+safe(info.sub)+'</small></span>'+arrow+'</button>';
  }
  function renderDay(day,opts){
    const items=itemsFor(day,opts.state);
    let out='',lastDate='';
    for(const item of items){
      if(day==='weekend'&&item.date!==lastDate)out+='<p class="feed-day">'+opts.esc(dayDates[item.date]||item.date)+'</p>';
      out+=row(item,opts);lastDate=item.date;
    }
    return '<div class="plan-feed'+(day==='weekend'?' week-list':'')+'">'+out+'</div>';
  }
  function renderWeek(opts){
    const items=itemsFor(null,opts.state).filter(item=>!opts.filter||opts.filter(item)),groups={};
    for(const item of items)(groups[item.date]??=[]).push(item);
    return Object.keys(groups).sort().map(date=>
      '<section class="week-group"><p class="feed-day">'+opts.esc(dayDates[date]||date)+'</p><div class="plan-feed">'+groups[date].map(item=>row(item,opts)).join('')+'</div></section>'
    ).join('');
  }
  globalThis.FuoriPlanFeed={extraEvents,itemsFor,renderDay,renderWeek};
})();
