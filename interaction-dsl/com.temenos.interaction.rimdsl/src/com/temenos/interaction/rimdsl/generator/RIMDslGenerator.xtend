/*
 * generated by Xtext
 */
package com.temenos.interaction.rimdsl.generator

import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.xtext.generator.IGenerator
import org.eclipse.xtext.generator.IFileSystemAccess
import com.temenos.interaction.rimdsl.rim.Command
import com.temenos.interaction.rimdsl.rim.State
import com.temenos.interaction.rimdsl.rim.Transition
import com.temenos.interaction.rimdsl.rim.TransitionForEach
import com.temenos.interaction.rimdsl.rim.TransitionAuto
import com.temenos.interaction.rimdsl.rim.ResourceInteractionModel
import org.eclipse.emf.common.util.EList

class RIMDslGenerator implements IGenerator {
	
	override void doGenerate(Resource resource, IFileSystemAccess fsa) {
		fsa.generateFile(resource.className+"Behaviour.java", toJavaCode(resource.contents.head as ResourceInteractionModel))
	}
	
	def className(Resource res) {
		var name = res.URI.lastSegment
		return name.substring(0, name.indexOf('.'))
	}
	
	def toJavaCode(ResourceInteractionModel rim) '''
		import java.util.HashSet;
		import java.util.Set;

		import com.temenos.interaction.core.hypermedia.Action;
		import com.temenos.interaction.core.hypermedia.CollectionResourceState;
		import com.temenos.interaction.core.hypermedia.ResourceState;
		import com.temenos.interaction.core.hypermedia.ResourceStateMachine;
		import com.temenos.interaction.core.hypermedia.validation.HypermediaValidator;
		
		public class �rim.eResource.className�Behaviour {
		
		    public static void main(String[] args) {
		        ResourceStateMachine hypermediaEngine = new �rim.eResource.className�Behaviour().getRIM();
		        HypermediaValidator validator = HypermediaValidator.createValidator(hypermediaEngine);
		        System.out.println(validator.graph());
		    }
		
			public ResourceStateMachine getRIM() {
				ResourceState initial = null;
				// create states
				�FOR c : rim.states�
					�c.produceResourceStates�
					�IF c.isInitial�
					// identify the initial state
					initial = s�c.name�;
					�ENDIF�
				�ENDFOR�

				// create regular transitions
				�FOR c : rim.states�
					�FOR t : c.transitions�
						�produceTransitions(c, t)�
					�ENDFOR�
				�ENDFOR�

		        // create foreach transitions
                �FOR c : rim.states�
                    �FOR t : c.transitionsForEach�
                        �produceTransitionsForEach(c, t)�
                    �ENDFOR�
                �ENDFOR�

		        // create AUTO transitions
                �FOR c : rim.states�
                    �FOR t : c.transitionsAuto�
                        �produceTransitionsAuto(c, t)�
                    �ENDFOR�
                �ENDFOR�

			    return new ResourceStateMachine(initial);
			}

		    private Set<Action> createActionSet(Action view, Action entry) {
		        Set<Action> actions = new HashSet<Action>();
		        if (view != null)
		            actions.add(view);
		        if (entry != null)
		            actions.add(entry);
		        return actions;
		    }

		}
	'''
	
	def produceResourceStates(State state) '''
            �IF state.entity.isCollection�
            CollectionResourceState s�state.name� = new CollectionResourceState("�state.entity.name�", "�state.name�", �produceActionSet(state.actions)�, "�if (state.path != null) { state.path.name }�");
            �ELSEIF state.entity.isItem�
            ResourceState s�state.name� = new ResourceState("�state.entity.name�", "�state.name�", �produceActionSet(state.actions)�, "�if (state.path != null) { state.path.name }�");
            �ENDIF�
	'''

    def produceActionSet(EList<Command> actions) '''
        �IF actions != null�
            �IF actions.size == 2�
            createActionSet(new Action("�actions.get(0).name�", Action.TYPE.VIEW), new Action("�actions.get(1).name�", Action.TYPE.ENTRY))�
            ELSEIF actions.size == 1�
            createActionSet(new Action("�actions.get(0).name�", Action.TYPE.VIEW), null)�
            ENDIF��
        ENDIF�'''
    
	def produceTransitions(State fromState, Transition transition) '''
			s�fromState.name�.addTransition("�transition.event.name�", s�transition.state.name�);
	'''

    def produceTransitionsForEach(State fromState, TransitionForEach transition) '''
            s�fromState.name�.addTransitionForEachItem("�transition.event.name�", s�transition.state.name�, null);
    '''
		
    def produceTransitionsAuto(State fromState, TransitionAuto transition) '''
            s�fromState.name�.addTransition(s�transition.state.name�);
    '''

}

